[![Gem Version](https://badge.fury.io/rb/mais-orcid-client.svg)](https://badge.fury.io/rb/mais-orcid-client)
[![CircleCI](https://circleci.com/gh/sul-dlss/mais-orcid-client.svg?style=svg)](https://circleci.com/gh/sul-dlss/mais-orcid-client)
[![Maintainability](https://api.codeclimate.com/v1/badges/5919e7ae4cd162861585/maintainability)](https://codeclimate.com/github/sul-dlss/mais-orcid-client/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5919e7ae4cd162861585/test_coverage)](https://codeclimate.com/github/sul-dlss/mais-orcid-client/test_coverage)

# mais-orcid-client
API client for accessing MAIS's ORCID endpoints.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add mais-orcid-client

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install mais-orcid-client

## Usage

For one-off requests:

```ruby
require "mais_orcid/client"

# NOTE: The settings below live in the consumer, not in the gem.
client = MaisOrcid::Client.configure(
  client_id: Settings.mais_orcid.client_id,
  client_secret: Settings.mais_orcid.client_secret,
  base_url: Settings.mais_orcid.base_url,
  transfer_endpoint_id: Settings.globus.transfer_endpoint_id
)
client.fetch_orcid_user(sunetid: 'nataliex')
```

You can also invoke methods directly on the client class, which is useful in a
Rails application environment where you might initialize the client in an
initializer and then invoke client methods in many other contexts where you want
to be sure configuration has already occurred, e.g.:

```ruby
# config/initializers/mais-orcid-client.rb
MaisOrcid::Client.configure(
  client_id: Settings.mais_orcid.client_id,
  client_secret: Settings.mais_orcid.client_secret,
  base_url: Settings.mais_orcid.base_url,
  transfer_endpoint_id: Settings.globus.transfer_endpoint_id
)

# app/services/my_mais_orcid_service.rb
# ...
def create_user_directory
  MaisOrcid::Client.fetch_orcid_user(sunetid: 'nataliex')
end
# ...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).