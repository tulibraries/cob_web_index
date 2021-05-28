# frozen_string_literal: true

RSpec.describe CobWebIndex do
  let(:indexer) {
    indexer = Traject::Indexer::MarcIndexer.new
    indexer.load_config_file("#{File.dirname(__FILE__)}/../lib/cob_web_index/indexer_config.rb")
    indexer
  }

  let(:mapped_record) { indexer.map_record(record) }

  it "has a version number" do
    expect(CobWebIndex::VERSION).not_to be nil
  end

  context "A Person Dataset is provided" do
    # keys MUST be strings or an error is thrown.
    let (:record) { {
      "type" => "person",
      "attributes" => {
        "job_title" => "worker",
        "email_address" => "foo@helloworld",
        "specialties" => [ "foo", "bar" ]
      }
    } }


    it "parses out the job title" do
      expect(mapped_record["web_job_title_display"]).to eq(["worker"])
    end

    it "parses the correct email address" do
      expect(mapped_record["web_email_address_display"]).to eq(["foo@helloworld"])
    end

    # TODO: look into why we are getting an array of arrays.
    it "parses the correct web_specialties_display" do
      expect(mapped_record["web_specialties_display"]).to eq([["foo", "bar"]])
    end
  end

  context "An unsupported type record is indexed" do
    # keys MUST be strings or an error is thrown.
    let (:record) { {
      "id" => "foo",
      "type" => "unsupported",
      "attributes" => {
        "job_title" => "worker",
        "email_address" => "foo@helloworld",
        "specialties" => [ "foo", "bar" ]
      }
    } }

    it "skips the record" do
      expect(mapped_record).to be_nil
    end
  end

  context "A record with a CONTENT_TYPE is indexed" do
    # keys MUST be strings or an error is thrown.
    let (:record) { {
      "id" => "foo-blog",
      "type" => "blog"
    } }

    it "ingests the record" do
      expect(mapped_record).to include({ "id" => ["blog_foo-blog"] })
    end
  end

  context "A a null dataset is passed in" do
    it "replaces the null dataset with an empty array" do
      null_data_file = { "data": nil }.to_json
      io = instance_double(IO)

      allow(Traject::Indexer::MarcIndexer).to receive(:new).and_return(indexer)
      allow(indexer).to receive_messages(load_config_file: "", process: "")
      allow(io).to receive_messages(read: null_data_file)
      allow(URI).to receive_messages(open: io)
      allow(StringIO).to receive(:new)

      expect(StringIO).to receive(:new).with("[]")
      CobWebIndex::CLI.ingest(ingest_path: null_data_file)
    end
  end

  context "URI open and read options" do
    let(:uri) { "https://example.com/documents.json" }
    let(:username) { "user" }
    let(:password) { "mypassword" }
    let(:read_timeout) { 12345 }

    before(:each) {
      ENV.clear
      allow(URI).to receive_message_chain(:open, :read)
    }

    it "receives no options" do
      expect(URI).to receive(:open).with(uri, {})
      CobWebIndex::CLI.open_read(uri)
    end

    it "handles authentication options" do
      ENV["WEB_CONTENT_BASIC_AUTH_USER"] = username
      ENV["WEB_CONTENT_BASIC_AUTH_PASSWORD"] = password

      expect(URI).to receive(:open).with(uri, { http_basic_authentication: [username, password] })
      CobWebIndex::CLI.open_read(uri)
    end

    it "handles read_timeout options" do
      ENV["WEB_CONTENT_READ_TIMEOUT"] = read_timeout.to_s

      expect(URI).to receive(:open).with(uri, { read_timeout: read_timeout })
      CobWebIndex::CLI.open_read(uri)
    end
  end
end
