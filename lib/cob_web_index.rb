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
      logger = indexer.logger

      if ingest_path
        logger.info "Ingesting #{ingest_path}"
        ingest_string = CobWebIndex::CLI.open_read(ingest_path)

        data = JSON.parse(ingest_string).fetch("data")

        # Protect against trying to ingest nil data
        if data.nil? || data.empty?
          logger.warn "Trying to ingest nil data at: #{ingest_path}"
          data = []
        end

        ingest_string = data.to_json
      end

      if opts[:delete_collection] && opts[:delete]
        indexer.writer.delete(query: "*:*")
      end


      indexer.process(StringIO.new(ingest_string))
    end

    def self.pull(opts = {})
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

          ingest(**opts.merge(ingest_path: url, delete_collection: delete.once))
        end
    end

    def self.open_read(url)
      options = {}
      if ENV["WEB_CONTENT_BASIC_AUTH_USER"] && ENV["WEB_CONTENT_BASIC_AUTH_PASSWORD"]
        options = { http_basic_authentication: [ENV["WEB_CONTENT_BASIC_AUTH_USER"], ENV["WEB_CONTENT_BASIC_AUTH_PASSWORD"]] }
      end
      options[:read_timeout] = ENV["WEB_CONTENT_READ_TIMEOUT"].to_i if ENV["WEB_CONTENT_READ_TIMEOUT"]
      file = options.empty? ? URI.open(url) : URI.open(url, options)
      file.read
    end

    def self.ingest_fixtures(opts = {})
      fixtures = "#{File.dirname(__FILE__)}/../spec/fixtures/*.json"
      delete = TrueOnce.new

      Dir.glob(fixtures).each do |file|
        ingest(**opts.merge(ingest_path: file, delete_collection: delete.once))
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
