require 'rails_helper'

RSpec.describe GetLocationData do
  let(:address) { Faker::Address.full_address }
  let(:latitude) { Faker::Address.latitude }
  let(:longitude) { Faker::Address.longitude }
  let(:zip) { Faker::Address.postcode }
  let(:error) { Geocoder::Error.new("mystery error") }

  let(:service) { GetLocationData.new(address) }

  before do
    stub_request(:get, %r{https://nominatim.openstreetmap.org/search.*})
      .to_return(
        status: 200,
        body: [
          {
            "lat" => latitude,
            "lon" => longitude,
            "address" => {
              "postcode" => zip.split('-').first
            },
            "display_name" => address
          }
        ].to_json,
        headers: {}
      )
  end

  describe "call" do
    it "returns a hash with verified coordinates, zip code, and address" do
      result = service.call

      expect(result).to be_a(Hash)
      expect(result[:coordinates][:latitude]).to eq(latitude.truncate(6))
      expect(result[:coordinates][:longitude]).to eq(longitude.truncate(6))
      expect(result[:zip]).to eq(zip.split('-').first)
      expect(result[:address]).to eq(address)
    end

    it "logs error message and returns nil if an error occurs" do
      allow(Geocoder).to receive(:search).and_raise(error)
      allow(Rails.logger).to receive(:error)
      result = service.call

      expect { result }.not_to raise_error
      expect(result).to be_nil
      expect(Rails.logger).to have_received(:error).with("Geocoder error: mystery error")
    end
  end
end
