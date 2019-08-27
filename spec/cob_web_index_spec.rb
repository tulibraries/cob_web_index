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

  context "An unsoported type record is indexed" do
    # keys MUST be strings or an error is thrown.
    let (:record) { {
      "id" => "foo",
      "type" => "unsopported",
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
end
