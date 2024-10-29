# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in cob_web_index.gemspec
gemspec

group :debug do
  gem "ruby-debug", platform: "jruby"

  gem "binding_of_caller", "~> 1.0", platform: "mri"
  gem "guard", "~> 2.19", platform: "mri"
  gem "guard-rspec", "~> 4.7", platform: "mri"
  gem "pry", "~> 0.14", platform: "mri"
  gem "pry-byebug", "~> 3.10", platform: "mri"
end
