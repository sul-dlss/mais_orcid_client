# frozen_string_literal: true

class MaisOrcidClient
  # The namespace for the "login" command
  class Authenticator
    attr_reader :client_id, :client_secret, :base_url

    def self.token(client_id, client_secret, base_url)
      new(client_id, client_secret, base_url).token
    end

    def initialize(client_id, client_secret, base_url)
      @client_id = client_id
      @client_secret = client_secret
      @base_url = base_url
    end

    # @return [String]
    def token
      client = OAuth2::Client.new(client_id, client_secret, site: base_url,
                                                            token_url: '/api/oauth/token',
                                                            authorize_url: '/api/oauth/authorize',
                                                            auth_scheme: :request_body)
      client.client_credentials.get_token.token
    end
  end
end
