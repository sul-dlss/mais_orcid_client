[![Gem Version](https://badge.fury.io/rb/mais_orcid_client.svg)](https://badge.fury.io/rb/mais_orcid_client)
[![CircleCI](https://circleci.com/gh/sul-dlss/mais_orcid_client.svg?style=svg)](https://circleci.com/gh/sul-dlss/mais_orcid_client)
[![Maintainability](https://api.codeclimate.com/v1/badges/5919e7ae4cd162861585/maintainability)](https://codeclimate.com/github/sul-dlss/mais_orcid_client/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5919e7ae4cd162861585/test_coverage)](https://codeclimate.com/github/sul-dlss/mais_orcid_client/test_coverage)

# mais_orcid_client
API client for accessing MAIS's ORCID endpoints.

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
  base_url: Settings.mais_orcid.base_url
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
2. Add your new spec with a new cassette name (or delete a cassette to re-create it).
3. Run just that new spec.
4. You should get a new cassette with the name you specified in the spec.
5. The cassette should have access tokens and secrets sanitized by the config in `spec_helper.rb`, but you can double check, EXCEPT for user access tokens in the user response.  These should be sanitized manaully (e.g. "access_token":"8d13b8bb-XXXX-YYYY-b7d6-87aecd5a8975")
6. Set your configuration at the top of the spec back to the fake client_id and client_secret values.
7. Re-run all the specs - they should pass now without making real calls.
