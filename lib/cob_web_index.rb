# frozen_string_literal: true

require "cob_web_index/version"
require "traject"
require "httparty"

module CobWebIndex
  module CLI
    def self.ingest(ingest_path: nil, ingest_string: "")
      indexer = Traject::Indexer::MarcIndexer.new("solr_writer.commit_on_close": true)
      indexer.load_config_file("#{File.dirname(__FILE__)}/cob_web_index/indexer_config.rb")

      if ingest_path
        ingest_string = open(ingest_path).read
        ingest_string = JSON.parse(ingest_string).fetch("data").to_json
      end

      indexer.writer.delete(query: "*:*")
      indexer.process(StringIO.new(ingest_string))
    end

    def self.pull
    end
  end
end
