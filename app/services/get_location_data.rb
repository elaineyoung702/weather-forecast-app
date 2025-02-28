require "geocoder"

class GetLocationData
  attr_reader :address

  def initialize(address)
    @address = address
  end

  def call
    begin
      result = Geocoder.search(address).first

      return nil unless result.present?

      verified_zip = result.postal_code.split("-").first
      verified_address = result.address

      {
        coordinates: get_coordinates(result.coordinates),
        zip: verified_zip,
        address: verified_address
      }
    rescue StandardError => e
      Rails.logger.error "Geocoder error: #{e.message}"
      nil
    end
  end

  private

  def get_coordinates(coordinates)
    { latitude: coordinates.first.truncate(6), longitude: coordinates.last.truncate(6) }
  end
end
