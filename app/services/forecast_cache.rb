class ForecastCache
  attr_reader :zip

  def initialize(zip)
    @zip = zip
  end

  def fetch
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) { yield }
  end

  def exists?
    Rails.cache.exist?(cache_key)
  end

  private

  def cache_key
    "forecast_#{zip}"
  end
end
