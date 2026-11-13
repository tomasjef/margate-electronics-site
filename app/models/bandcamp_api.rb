require "net/http"

# Bandcamp's API, read only: the label's merch and how many of each are left.
# Keys from the environment (BANDCAMP_CLIENT_ID, BANDCAMP_CLIENT_SECRET): in
# .env on the Mac, in GitHub's secrets for the deploy.
class BandcampApi
  Error = Class.new(StandardError)

  BASE = "https://bandcamp.com"
  SUBDOMAIN = "margate-electronics"

  def self.configured? = ENV["BANDCAMP_CLIENT_ID"].present? && ENV["BANDCAMP_CLIENT_SECRET"].present?

  # Every merch item, with its options (sizes) and quantities left
  def merch
    token = access_token
    bands = post("/api/account/1/my_bands", {}, token:).fetch("bands", [])
    band = bands.find { |b| b["subdomain"] == SUBDOMAIN } or raise Error, "no band #{SUBDOMAIN} on this Bandcamp account"
    post("/api/merchorders/1/get_merch_details", { band_id: band["band_id"], start_time: "2000-01-01 00:00:00" }, token:)
      .fetch("items", [])
  end

  private

  def access_token
    form = { grant_type: "client_credentials", client_id: ENV.fetch("BANDCAMP_CLIENT_ID"), client_secret: ENV.fetch("BANDCAMP_CLIENT_SECRET") }
    post("/oauth_token", form, form: true).fetch("access_token") { raise Error, "Bandcamp gave no access token" }
  end

  def post(path, body, token: nil, form: false)
    uri = URI("#{BASE}#{path}")
    request = Net::HTTP::Post.new(uri)
    if form
      request.set_form_data(body)
    else
      request.body = body.to_json
      request["Content-Type"] = "application/json"
    end
    request["Authorization"] = "Bearer #{token}" if token
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 20) { |http| http.request(request) }
    raise Error, "Bandcamp answered #{response.code} for #{path}" unless response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    raise Error, "Bandcamp: #{data["error_message"]}" if data["error"]
    data
  rescue JSON::ParserError, SocketError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => e
    raise Error, "Bandcamp couldn't be reached (#{e.class})"
  end
end
