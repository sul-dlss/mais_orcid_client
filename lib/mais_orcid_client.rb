# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/hash/indifferent_access"

require "faraday"
require "faraday/retry"
require "oauth2"
require "singleton"
require "zeitwerk"

# Load the gem's internal dependencies: use Zeitwerk instead of needing to manually require classes
Zeitwerk::Loader.for_gem.setup

# Client for interacting with MAIS's ORCID API
class MaisOrcidClient
  include Singleton

  # Struct for ORCID-relating data returned from API.
  OrcidUser = Struct.new(:sunetid, :orcidid, :scope, :access_token, :last_updated) do
    def update?
      scope.include?("/activities/update")
    end
  end

  class << self
    # @param client_id [String] the client identifier registered with MAIS
    # @param client_secret [String] the client secret to authenticate with MAIS
    # @param base_url [String] the base URL for the API
    def configure(client_id:, client_secret:, base_url:)
      instance.base_url = base_url
      instance.client_id = client_id
      instance.client_secret = client_secret
      self
    end

    delegate :fetch_orcid_users, :fetch_orcid_user, to: :instance
  end

  attr_accessor :base_url, :client_id, :client_secret

  # @param [int] limit number of users requested
  # @param [int] page_size number of users per page
  # @return [Array<OrcidUser>] orcid users
  def fetch_orcid_users(limit: nil, page_size: nil)
    orcid_users = []
    next_page = first_page(page_size)
    loop do
      response = get_response(next_page)
      response[:results].each do |result|
        orcid_users << OrcidUser.new(result[:sunet_id], result[:orcid_id], result[:scope], result[:access_token], result[:last_updated])
        return orcid_users if limit && limit == orcid_users.size
      end
      # Currently next is always present, even on last page. (This may be changed in future.)
      next_page = response.dig(:links, :next)
      return orcid_users if last_page?(response[:links])
    end
  end

  # @param [string] sunet to fetch
  # @return [<OrcidUser>, nil] orcid user or nil if not found
  def fetch_orcid_user(sunetid:)
    result = get_response("/users/#{sunetid}", allow404: true)

    return if result.nil?

    OrcidUser.new(result[:sunet_id], result[:orcid_id], result[:scope], result[:access_token], result[:last_updated])
  end

  private

  def first_page(page_size)
    path = "/users?scope=ANY"
    path += "&page_size=#{page_size}" if page_size
    path
  end

  def last_page?(links)
    links[:self] == links[:last]
  end

  def get_response(path, allow404: false)
    response = conn.get("/mais/orcid/v1#{path}")

    return if allow404 && response.status == 404

    raise "UIT MAIS ORCID User API returned #{response.status}" if response.status != 200

    body = JSON.parse(response.body).with_indifferent_access
    raise "UIT MAIS ORCID User API returned an error: #{response.body}" if body.key?(:error)

    body
  end

  # @return [Faraday::Connection]
  def conn
    @conn ||= begin
      conn = Faraday.new(url: base_url) do |faraday|
        faraday.request :retry, max: 3,
          interval: 0.5,
          interval_randomness: 0.5,
          backoff_factor: 2
      end
      conn.options.timeout = 500
      conn.options.open_timeout = 10
      conn.headers[:user_agent] = "stanford-library-sul-pub"
      conn.headers[:authorization] = token
      conn
    end
  end

  def token
    client = OAuth2::Client.new(client_id, client_secret, site: base_url,
      token_url: "/api/oauth/token", authorize_url: "/api/oauth/authorize",
      auth_scheme: :request_body)
    token = client.client_credentials.get_token
    "Bearer #{token.token}"
  end
end
