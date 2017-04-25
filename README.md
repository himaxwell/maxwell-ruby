# Maxwell Ruby

Ruby bindings for the Maxwell API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'maxwell-ruby', git: 'https://github.com/himaxwell/maxwell-ruby.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install maxwell-ruby

## Usage

After gem installation is complete, the easiest way to get setup is to add an initializer, setting the `base_url`

```ruby
require 'maxwell'

Maxwell::Client.base_url = Rails.application.secrets.maxwell_base_api_url
```

If you've been supplied an API key, you can also set that in the initializer

```ruby
require 'maxwell'

Maxwell::Client.base_url = Rails.application.secrets.maxwell_base_api_url
Maxwell::Client.token = Rails.application.secrets.maxwell_api_key
```

If you haven't been supplied an API key, the alternative is to authenticate requests with a `JWT`

```ruby
require 'maxwell'

Maxwell::Client.base_url = Rails.application.secrets.maxwell_base_api_url

res = Maxwell::Client.authenticate({ email: "example@example.com", password: 'password' })
auth_hash = JSON.parse(res.body)
auth_hash
=> { "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjYwLCJ0eXBlIjoiVXNlciIsImV4cCI6MTQ5MzE0OTg1OX0.guHsHyN0wETey_8mXOUfRRPsdcYLduk1bVPqk0hNbvE" }

Maxwell::Client.get('/api_endpoint', auth_hash)
```

Please inquire if you'd like access to our API documentation.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/maxwell-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

