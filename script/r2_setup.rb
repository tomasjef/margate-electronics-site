# Run with bin/r2-setup. See that file for what it's for.
#
# 1. Allows browsers on any https site to stream from the public bucket (CORS).
# 2. Copies the audio from Backblaze's public archivalrecs bucket:
#    - recordings at the top level -> the public bucket, same names (the pages
#      link to them by those names)
#    - the full Systems EP (TM002) and Tactile Machines (TM001) tracks -> the
#      private masters bucket, under the release's slug, never public on R2.
#      They're Tomas's own releases for tomasjef.com, not Margate Electronics,
#      so they're kept there but not added to this site.
#    Videos and the old site's tracks.json stay in Backblaze only.
require "aws-sdk-s3"
require "net/http"
require "tmpdir"

RELEASE_FOLDERS = { "Systems EP" => "systems-ep", "Tactile Machines" => "tactile-machines" }.freeze
B2_PUBLIC = "https://archivalrecs.s3.eu-central-003.backblazeb2.com"

%w[R2_ACCOUNT_ID R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY].each do |name|
  abort "#{name} is missing from .env (see .env.example)" if ENV[name].to_s.empty?
end

media = R2Storage.configurations.fetch("cloudflare_r2")
masters = R2Storage.configurations.fetch("cloudflare_r2_masters")
r2 = Aws::S3::Client.new(
  access_key_id: media["access_key_id"], secret_access_key: media["secret_access_key"],
  region: "auto", endpoint: media["endpoint"], force_path_style: true,
  request_checksum_calculation: "when_required", response_checksum_validation: "when_required"
)
PUBLIC_BUCKET = media["bucket"]
MASTERS_BUCKET = masters["bucket"]

# 1. CORS on the public bucket
begin
  r2.put_bucket_cors(bucket: PUBLIC_BUCKET, cors_configuration: { cors_rules: [ {
    allowed_origins: [ "*" ], allowed_methods: %w[GET HEAD], allowed_headers: [ "Range" ],
    expose_headers: %w[Content-Length Content-Range Accept-Ranges], max_age_seconds: 86_400
  } ] })
  puts "CORS: set on #{PUBLIC_BUCKET}"
rescue Aws::S3::Errors::AccessDenied
  puts "CORS: this key may not change bucket settings. In the dashboard: R2 > #{PUBLIC_BUCKET} > " \
       "Settings > CORS policy, allow GET and HEAD from any origin."
end

# 2. What Backblaze holds (listing needs the B2 key; reading the files doesn't)
creds = Rails.application.credentials.backblaze
auth_uri = URI("https://api.backblazeb2.com/b2api/v3/b2_authorize_account")
request = Net::HTTP::Get.new(auth_uri)
request.basic_auth(creds[:key_id], creds[:application_key])
auth = JSON.parse(Net::HTTP.start(auth_uri.host, 443, use_ssl: true) { |http| http.request(request) }.body)
api = auth.dig("apiInfo", "storageApi", "apiUrl")
b2_post = lambda do |path, body|
  uri = URI("#{api}/b2api/v3/#{path}")
  post = Net::HTTP::Post.new(uri, "Authorization" => auth["authorizationToken"], "Content-Type" => "application/json")
  post.body = body.to_json
  JSON.parse(Net::HTTP.start(uri.host, 443, use_ssl: true) { |http| http.request(post) }.body)
end
bucket_id = b2_post.("b2_list_buckets", { accountId: auth["accountId"], bucketName: "archivalrecs" })["buckets"].first["bucketId"]
files = []
start = nil
loop do
  page = b2_post.("b2_list_file_names", { bucketId: bucket_id, maxFileCount: 1000, startFileName: start }.compact)
  files.concat(page["files"])
  break unless (start = page["nextFileName"])
end

# Where each audio file goes on R2, or nil to leave it in Backblaze only
destination = lambda do |name|
  return unless name.match?(/\.(mp3|wav|flac|aiff?|m4a)\z/i)
  folder, file = name.include?("/") ? name.split("/", 2) : [ nil, name ]
  return [ PUBLIC_BUCKET, name ] if folder.nil?
  return [ MASTERS_BUCKET, "#{RELEASE_FOLDERS.fetch(folder)}/#{file}" ] if RELEASE_FOLDERS.key?(folder)
  nil
end

copied = skipped = 0
left = []
Dir.mktmpdir do |dir|
  files.each do |f|
    name = f["fileName"]
    bucket, key = destination.(name)
    unless bucket
      left << name unless name.end_with?(".bzEmpty")
      next
    end
    size = f["contentLength"]
    existing = begin
      r2.head_object(bucket: bucket, key: key).content_length
    rescue Aws::S3::Errors::NotFound
      nil
    end
    if existing == size
      skipped += 1
      next
    end

    local = File.join(dir, "file")
    source = URI("#{B2_PUBLIC}/#{MediaUrls.encode_path(name)}")
    Net::HTTP.start(source.host, 443, use_ssl: true) do |http|
      http.request(Net::HTTP::Get.new(source)) do |response|
        raise "Backblaze #{response.code} for #{name}" unless response.is_a?(Net::HTTPSuccess)
        File.open(local, "wb") { |out| response.read_body { |chunk| out.write(chunk) } }
      end
    end
    raise "#{name}: downloaded #{File.size(local)} bytes, expected #{size}" unless File.size(local) == size

    Aws::S3::TransferManager.new(client: r2)
      .upload_file(local, bucket: bucket, key: key, content_type: "audio/mpeg", multipart_threshold: 100 * 1024 * 1024)
    copied += 1
    puts format("copied  %-8s %6.1f MB  %s -> %s", bucket == PUBLIC_BUCKET ? "public" : "private", size / 1e6, name, key)
  end
end

puts "\n#{copied} copied, #{skipped} already there. Left in Backblaze only: #{left.size} files (#{left.count { _1.start_with?("videos/") }} videos)"
puts "  #{left.reject { _1.start_with?("videos/") }.join(", ")}" if left.any? { !_1.start_with?("videos/") }
