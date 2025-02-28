require "net/http"

class RetrieveForecastData
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def call
    begin
      response = Net::HTTP.get(get_uri)
      JSON.parse(response)
    rescue StandardError => e
      Rails.logger.error("Open-Meteo Weather API Error: #{e.message}")
      nil
    end
  end

  private

  def get_uri
    latitude = coordinates[:latitude]
    longitude = coordinates[:longitude]

    URI("https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit")
  end
end
