class ParseForecastData
  attr_reader :data

  def initialize(forecast_data)
    @data = forecast_data
  end

  def call
    {
      current_temp: get_current_temp,
      daily_temps: get_daily_temps
    }
  end

  private

  def get_current_temp
    temperature = data["current"]["temperature_2m"]
    unit = data["current_units"]["temperature_2m"]
    "#{temperature} #{unit}"
  end

  def get_daily_temps
    unit = data["daily_units"]["temperature_2m_max"]

    dates = data["daily"]["time"]
    high_temps = data["daily"]["temperature_2m_max"]
    low_temps = data["daily"]["temperature_2m_min"]

    dates.zip(high_temps, low_temps).map do |date, high, low|
      {
        date: date,
        high: "#{high} #{unit}",
        low: "#{low} #{unit}"
      }
    end
  end
end
