# frozen_string_literal: true

require "cob_web_index/version"
require "traject"
require "httparty"
require "pry"

module CobWebIndex
  module CLI
    def self.ingest(ingest_path: nil, ingest_string: "")
      indexer = Traject::Indexer::MarcIndexer.new("solr_writer.commit_on_close": true)
      indexer.load_config_file("#{File.dirname(__FILE__)}/cob_web_index/indexer_config.rb")

      if ingest_path
        ingest_string = open_read(ingest_path)
        ingest_string = JSON.parse(ingest_string).fetch("data").to_json
      end

      indexer.writer.delete(query: "*:*")
      indexer.process(StringIO.new(ingest_string))
    end

    def self.pull
    end

    def self.open_read(url)
      if ENV["WEB_CONTENT_BASIC_AUTH_USER"] &&  ENV["WEB_CONTENT_BASIC_AUTH_PASSWORD"]
        user = ENV["WEB_CONTENT_BASIC_AUTH_USER"]
        password = ENV["WEB_CONTENT_BASIC_AUTH_PASSWORD"]
        open(url, http_basic_authentication: [user, password]).read
      else
        open(url).read
      end
    end

    def self.ingest_fixtures
      fixtures = "#{File.dirname(__FILE__)}/../spec/fixtures/*.json"

      Dir.glob(fixtures).each do |file|
        ingest(ingest_path: file)
      end
    end
  end
end
