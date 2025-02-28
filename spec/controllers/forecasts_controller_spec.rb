require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  let(:street) { Faker::Address.street_address }
  let(:city) { Faker::Address.city }
  let(:state) { Faker::Address.state }
  let(:zip) { Faker::Address.postcode }

  let(:params) do
    { street: street, city: city, state: state, zip: zip }
  end

  let(:invalid_params) do
    { street: "street", city: "city", state: "state", zip: "zip" }
  end

  let(:address) { "#{street}, #{city}, #{state}, #{zip}" }
  let(:latitude) { Faker::Address.latitude }
  let(:longitude) { Faker::Address.longitude }
  let(:coordinates) { { latitude: latitude.truncate(6), longitude: longitude.truncate(6)  } }
  let(:forecast_data) { { "current" => { "temperature_2m" => 72.0 } } }

  let(:parsed_data) do
    {
      current_temp: "75°F",
      daily_temps: [
        { date: "2025-02-27", high: "88°F", low: "68°F" },
        { date: "2025-03-01", high: "87°F", low: "67°F" }
      ]
    }
  end

  let(:error) { Timeout::Error.new("execution expired") }

  describe "GET index" do
    it "responds with 200" do
      get :index, format: :html
      expect(response).to have_http_status(200)
    end
  end

  describe "GET show" do
    let(:get_show) { get :show, params: params, format: :html }

    before do
      allow(GetLocationData).to receive(:new).with(address)
        .and_return(double(call: { coordinates: coordinates, zip: zip, address: address }))

      allow(RetrieveForecastData).to receive(:new).with(coordinates)
        .and_return(double(call: forecast_data))

      allow(ParseForecastData).to receive(:new).with(forecast_data)
        .and_return(double(call: parsed_data))
    end

    it "responds with 200" do
      get_show
      expect(response).to have_http_status(:ok)
    end

    it "calls the necessary services" do
      expect(ForecastCache).to receive(:new).with(zip).and_call_original
      expect(GetLocationData).to receive(:new).with(address)
      expect(RetrieveForecastData).to receive(:new).with(coordinates)
      expect(ParseForecastData).to receive(:new).with(forecast_data)

      get_show
    end

    context "when errors are encountered" do
      it "redirects when address is blank" do
        get :show, params: {}, format: :html

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Please provide an address")
      end

      it "redirects if address is invalid" do
        allow(GetLocationData).to receive(:new).with(address).and_return(double(call: nil))
        get_show

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Invalid address")
      end

      it "redirects if there is an API error" do
        allow(RetrieveForecastData).to receive(:new).with(coordinates).and_raise(error)
        allow(Rails.logger).to receive(:error)
        get_show

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Whoops - something went wrong. Please try again")
        expect(Rails.logger).to have_received(:error).with("Unexpected Error: execution expired")
      end
    end
  end
end
