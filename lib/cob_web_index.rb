# frozen_string_literal: true

require "cob_web_index/version"
require "traject"
require "httparty"

module CobWebIndex
  class WebContentError < StandardError
  end

  module CLI
    def self.ingest(ingest_path: nil, ingest_string: "", **opts)
      indexer = Traject::Indexer::MarcIndexer.new("solr_writer.commit_on_close": true)
      indexer.load_config_file("#{File.dirname(__FILE__)}/cob_web_index/indexer_config.rb")

      if ingest_path
        ingest_string = open_read(ingest_path)
        ingest_string = JSON.parse(ingest_string).fetch("data").to_json
      end

      if opts[:delete_collection] && opts[:delete]
        indexer.writer.delete(query: "*:*")
      end

      indexer.process(StringIO.new(ingest_string))
    end

    def self.pull(opts={})
      raise WebContentError.new("No WEB_CONTENT_BASE_URL provided.") unless ENV["WEB_CONTENT_BASE_URL"]

      base_url = ENV["WEB_CONTENT_BASE_URL"]
      swagger_api = open_read("#{base_url}/swagger.json")
      swagger_api = JSON.parse(swagger_api)
      delete = TrueOnce.new

      swagger_api["paths"]
        .select { |path, api| !api["get"].nil? }
        .keys
        .each do |path|
          url = "#{base_url}#{path}.json"

          ingest(opts.merge(ingest_path: url, delete_collection: delete.once))
        end
    end

    def self.open_read(url)
      if ENV["WEB_CONTENT_BASIC_AUTH_USER"] && ENV["WEB_CONTENT_BASIC_AUTH_PASSWORD"]
        user = ENV["WEB_CONTENT_BASIC_AUTH_USER"]
        password = ENV["WEB_CONTENT_BASIC_AUTH_PASSWORD"]
        open(url, http_basic_authentication: [user, password]).read
      else
        open(url).read
      end
    end

    def self.ingest_fixtures(opts={})
      fixtures = "#{File.dirname(__FILE__)}/../spec/fixtures/*.json"
      delete = TrueOnce.new

      Dir.glob(fixtures).each do |file|
        ingest(opts.merge(ingest_path: file, delete_collection: delete.once))
      end
    end
  end

  class TrueOnce
    def once
      if !@once
        @once = true
        true
      else
        false
      end
    end
  end
end
