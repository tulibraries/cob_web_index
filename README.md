# CobWebIndex
[![Build Status](https://travis-ci.org/tulibraries/cob_web_index.svg?branch=master)](https://travis-ci.org/tulibraries/cob_web_index)
[![Coverage Status](https://coveralls.io/repos/github/tulibraries/cob_web_index/badge.svg?branch=master)](https://coveralls.io/github/tulibraries/cob_web_index?branch=master)

Cob Index is a repository to hold the traject configuration files and scripts associated with indexing of the library website entities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cob_web_index'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cob_web_index

## Usage

`cob_web_index` is an executable.  You can use it to ingest files into SOLR_WEB_URL with

```
cob_web_index ingest $path_to_file
```

`$path_to_file` can also be a URL.

Note also that `$path_to_file` is an optional argument. If not provided then by default ingest will attempt to download the latest website dataset and import that.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Ingest Fixture Files
`cob_web_index ingest --use-fixtures`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tulibraries/cob_web_index. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CobWebIndex project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tulibraries/cob_web_index/blob/master/CODE_OF_CONDUCT.md).
