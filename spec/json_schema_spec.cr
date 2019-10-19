require "./spec_helper"

describe JSON do
  it "works" do
    JSON::Schema.from_json(File.read "#{__DIR__}/schema.json").validate(JSON.parse(File.read "#{__DIR__}/data.json"))
    true.should eq(true)
  end
end
