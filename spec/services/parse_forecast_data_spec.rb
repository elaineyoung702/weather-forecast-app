require 'rails_helper'

RSpec.describe ParseForecastData do
  let(:forecast_data) do
    {
      "current_units" => {
        "temperature_2m" => "°F"
      },
      "current" => {
        "temperature_2m" => 88
      },
      "daily" => {
        "temperature_2m_min" => [ 35, 36, 27, 35, 47, 56, 65 ],
        "temperature_2m_max" => [ 45, 45, 46, 47, 56, 57, 72 ],
        "time" => [ "2025-02-27", "2025-02-28", "2025-03-01", "2025-03-02", "2025-03-03", "2025-03-04", "2025-03-05" ]
      },
      "daily_units" => {
        "temperature_2m_max" => "°F"
      }
    }
  end

  let(:service) { ParseForecastData.new(forecast_data) }

  describe "call" do
    it "returns a hash of current temp and daily temps" do
      result = service.call

      expect(result).to include(:current_temp, :daily_temps)
      expect(result[:current_temp]).to eq("88 °F")
      expect(result[:daily_temps]).to be_an(Array)
      expect(result[:daily_temps].count).to eq(7)
    end
  end
end
