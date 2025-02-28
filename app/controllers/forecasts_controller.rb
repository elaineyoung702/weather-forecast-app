class ForecastsController < ApplicationController
  def index
  end

  def show
    @address = address_params

    if @address.blank?
      redirect_to root_path, alert: "Please provide an address"
      return
    end

    location_data = get_location_data
    return redirect_to root_path, alert: "Invalid address" unless location_data

    @coordinates = location_data[:coordinates]
    @verified_zip = location_data[:zip]
    @verified_address = location_data[:address]

    cache = ForecastCache.new(@verified_zip)
    @cached = cache.exists?

    @forecast_data = retrieve_forecast_data(cache)

    if @forecast_data
      parsed_data = parse_forecast_data

      @current_temp = parsed_data[:current_temp]
      @daily_temps = parsed_data[:daily_temps]
    end

  rescue StandardError => e
    Rails.logger.error("Unexpected Error: #{e.message}")
    redirect_to root_path, alert: "Whoops - something went wrong. Please try again"
  end

  private

  def address_params
    params.except(:commit).permit(:street, :city, :state, :zip).to_h.values.compact.join(", ")
  end

  def get_location_data
    GetLocationData.new(@address).call
  end

  def retrieve_forecast_data(cache)
    cache.fetch { RetrieveForecastData.new(@coordinates).call }
  end

  def parse_forecast_data
    ParseForecastData.new(@forecast_data).call
  end
end
