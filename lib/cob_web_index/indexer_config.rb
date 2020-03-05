# frozen_string_literal: true

$:.unshift "./lib" if !$:.include?("./lib")
require "traject_plus"
require "traject_plus/json_reader.rb"
require "traject_plus/macros"
require "traject_plus/macros/json"
require "cob_web_index/macros"
require "nokogiri"

extend TrajectPlus::Macros
extend TrajectPlus::Macros::JSON
extend CobWebIndex::Macros

if File.exist? "config/blacklight.yml"
  solr_config = YAML.load_file("config/blacklight.yml")[(ENV["RAILS_ENV"] || "development")]
  solr_url = ERB.new(solr_config["web_content_url"]).result
else
  solr_url = ENV["SOLR_WEB_URL"]
end

settings do
  provide "reader_class_name", "TrajectPlus::JsonReader"
  provide "solr_writer.commit_timeout", (15 * 60)
  provide "solr.url", solr_url
  provide "solr_writer.commit_on_close", "false"

  # set this to be non-negative if threshold should be enforced
  provide "solr_writer.max_skipped", 0

  if ENV["SOLR_AUTH_USER"] && ENV["SOLR_AUTH_PASSWORD"]
    provide "solr_writer.basic_auth_user", ENV["SOLR_AUTH_USER"]
    provide "solr_writer.basic_auth_password", ENV["SOLR_AUTH_PASSWORD"]
  end
end

WEBSITE_TYPES = /space|service|policy|collection|form/i
CONTENT_TYPES = /person|event|exhibition|space|service|policy|collection|form/i

to_field "id", ->(rec, acc) {
  acc << "#{rec['type']}_#{rec['id']}"
}

to_field "web_content_type_facet", ->(rec, acc, context) {
  if rec.fetch("type").match(WEBSITE_TYPES)
    acc << rec.fetch("type")
  end

  if rec.fetch("type") == "building"
    acc << "Library"
  end

  if rec.fetch("type") == "webpage"
    acc << "Pages"
  end

  if rec.fetch("type") == "person"
    acc << "People/Staff Directory"
  end

  if rec.fetch("type") == "event" || rec.fetch("type") == "exhibition"
    acc << "Events and Exhibits"
  end

  if rec.fetch("type") == "finding_aid"
    acc << "Finding Aids"
  end

  if acc.empty?
    context.skip!("Skipping unsupported type #{rec.fetch("type")}: #{context.output_hash["id"]}")
  end
}


to_field "web_content_type_t", ->(rec, acc) {
  if rec.fetch("type").match(CONTENT_TYPES)
    acc << rec.fetch("type")
  end

  if rec.fetch("type") == "building"
    acc << "Library"
  end

  if rec.fetch("type") == "finding_aid"
    acc << "Finding Aids"
  end
}

to_field "web_title_display", extract_json("$.attributes.label")
to_field "title_sort", extract_json("$.attributes.label")

# Same issue as descriptions.  Should only appear for people, not buildings.
to_field "web_phone_number_display", extract_json("$.attributes.phone_number")

to_field "web_photo_display", extract_json("$.attributes.thumbnail_image")
to_field "web_subject_display", extract_json("$.attributes.subject")
to_field "web_base_url_display", extract_json("$.attributes.base_url")
to_field "web_url_display", extract_json("$.links.self")

# This attribute isn't displayed for every entity that contains it
# What is the best way to suppress this for entities that don't use it?
to_field "web_description_display", ->(rec, acc) {
  if rec.dig("attributes", "description")
    acc << Nokogiri::HTML(rec.dig("attributes", "description")).text
  end
}, &truncate(100)


# make sure the ful index is searchable
to_field "web_full_description_t", ->(rec, acc) {
  if rec.dig("attributes", "description")
    acc << Nokogiri::HTML(rec.dig("attributes", "description")).text
  end
}



#person specific
to_field "web_job_title_display", extract_json("$.attributes.job_title")
to_field "web_email_address_display", extract_json("$.attributes.email_address")
to_field "web_specialties_display", extract_json("$.attributes.specialties")

#highlight specific
to_field "web_blurb_display", extract_json("$.attributes.blurb")
to_field "web_tags_display", extract_json("$.attributes.tags")
to_field "web_link_display", extract_json("$.attributes.link")

# we need update times from the JSON responses.
# Ticketed in MAN-242
# It seems that this work has been done, not sure if anything here needs
# to be altered in order for it to work
each_record do |record, context|
  context.output_hash["record_update_date"] = [ Time.now.to_s ]
end
