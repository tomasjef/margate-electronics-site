require "aws-sdk-s3"

# Direct file operations on the two R2 buckets, for the audio work that isn't
# an Active Storage upload: moving a release's full file into place, reading
# it back and putting its preview clip in the public bucket. Uses the same
# settings as the Active Storage services in config/storage.yml.
class R2Storage
  # Active Storage reads config/storage.yml only once its Blob model loads
  def self.configurations
    ActiveStorage::Blob.services
    Rails.configuration.active_storage.service_configurations
  end

  def initialize(config = self.class.configurations)
    media = config.fetch("cloudflare_r2")
    @buckets = { media: media.fetch("bucket"), masters: config.fetch("cloudflare_r2_masters").fetch("bucket") }
    @client = Aws::S3::Client.new(
      access_key_id: media["access_key_id"], secret_access_key: media["secret_access_key"],
      region: "auto", endpoint: media["endpoint"], force_path_style: true,
      request_checksum_calculation: "when_required", response_checksum_validation: "when_required"
    )
  end

  # bucket: :media (public) or :masters (private)
  def download(bucket, key, to:)
    @client.get_object(bucket: @buckets.fetch(bucket), key: key, response_target: to.to_s)
  end

  def upload(bucket, key, from:, content_type:)
    Aws::S3::TransferManager.new(client: @client)
      .upload_file(from.to_s, bucket: @buckets.fetch(bucket), key: key, content_type: content_type)
  end

  def copy(bucket, from_key, to_key)
    name = @buckets.fetch(bucket)
    @client.copy_object(bucket: name, key: to_key, copy_source: "#{name}/#{MediaUrls.encode_path(from_key)}")
  end

  def delete(bucket, key)
    @client.delete_object(bucket: @buckets.fetch(bucket), key: key)
  end
end
