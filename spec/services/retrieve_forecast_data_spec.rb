require 'rails_helper'

RSpec.describe RetrieveForecastData do
  let(:latitude) { Faker::Address.latitude }
  let(:longitude) { Faker::Address.longitude }
  let(:coordinates) do
    { latitude: latitude, longitude: longitude }
  end
  let(:error) { Timeout::Error.new("execution expired") }

  let(:service) { RetrieveForecastData.new(coordinates) }

  before do
    stub_request(:get, "https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit")
      .to_return(
        status: 200,
        body: {
          "latitude" => latitude,
          "longitude" => longitude,
          "current" => { "temperature_2m" => 72.0 },
          "current_units" => { "temperature_2m" => "°F" }
        }.to_json,
        headers: {}
      )
  end

  describe "call" do
    it "calls the open-meteo api using location coordinates and returns parsed JSON" do
      result = service.call

      expect(result).to be_a(Hash)
      expect(result["latitude"]).to eq(latitude)
      expect(result["longitude"]).to eq(longitude)
      expect(result["current"]["temperature_2m"]).to eq(72.0)
      expect(result["current_units"]["temperature_2m"]).to eq("°F")
    end

    it "logs error message and returns nil if an error occurs" do
      allow(Net::HTTP).to receive(:get).and_raise(error)
      allow(Rails.logger).to receive(:error)
      result = service.call

      expect { result }.not_to raise_error
      expect(result).to be_nil
      expect(Rails.logger).to have_received(:error).with("Open-Meteo Weather API Error: execution expired")
    end
  end
end
