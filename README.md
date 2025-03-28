[![Gem Version](https://badge.fury.io/rb/mais_orcid_client.svg)](https://badge.fury.io/rb/mais_orcid_client)
[![CircleCI](https://circleci.com/gh/sul-dlss/mais_orcid_client.svg?style=svg)](https://circleci.com/gh/sul-dlss/mais_orcid_client)
[![codecov](https://codecov.io/github/sul-dlss/mais_orcid_client/graph/badge.svg?token=A6B03FJ981)](https://codecov.io/github/sul-dlss/mais_orcid_client)

# mais_orcid_client
API client for accessing MAIS's ORCID endpoints.

MAIS's ORCID API provides access to ORCID information for Stanford users. (This is different from orcid.org's ORCID API, which is supported by https://github.com/sul-dlss/orcid_client.)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add mais_orcid_client

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install mais_orcid_client

## Usage

For one-off requests:

```ruby
require "mais_orcid_client"

# NOTE: The settings below live in the consumer, not in the gem.
client = MaisOrcidClient.configure(
  client_id: Settings.mais_orcid.client_id,
  client_secret: Settings.mais_orcid.client_secret,
  base_url: Settings.mais_orcid.base_url
  token_url: Settings.mais_orcid.token_url
)
client.fetch_orcid_user(sunetid: 'nataliex')
```

You can also invoke methods directly on the client class, which is useful in a
Rails application environment where you might initialize the client in an
initializer and then invoke client methods in many other contexts where you want
to be sure configuration has already occurred, e.g.:

```ruby
# config/initializers/mais_orcid_client.rb
MaisOrcidClient.configure(
  client_id: Settings.mais_orcid.client_id,
  client_secret: Settings.mais_orcid.client_secret,
  base_url: Settings.mais_orcid.base_url,
  token_url: Settings.mais_orcid.token_url
)

# app/services/my_mais_orcid_service.rb
# ...
def create_user_directory
  MaisOrcidClient.fetch_orcid_user(sunetid: 'nataliex')
end
# ...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## VCR Cassettes

VCR gem is used to record the results of the API calls for the tests.  If you need to
record or re-create existing cassettes, you may need to adjust expectations in the tests
as the results coming back from the API may be different than when the cassettes were
recorded.

To record new cassettes:
1. Temporarily adjust the configuration (client_id, client_secret for the MaIS UAT URL) at the top of `spec/mais_orcid_client_spec.rb` so it matches the real MaIS UAT environment.
2. Add your new spec with a new cassette name (or delete a previous cassette to re-create it).
3. Run just that new spec (important: else previous specs may use cassettes that have redacted credentials, causing your new spec to fail).
4. You should get a new cassette with the name you specified in the spec.
5. The cassette should have access tokens and secrets sanitized by the config in `spec_helper.rb`, but you can double check.
6. Set your configuration at the top of the spec back to the fake client_id and client_secret values.
7. The spec that checks for a raised exception when fetching all users may need to be handcrafted in the cassette to look it raised a 500.  It's hard to get the actual URL to produce a 500 on this call.
7. Re-run all the specs - they should pass now without making real calls.
