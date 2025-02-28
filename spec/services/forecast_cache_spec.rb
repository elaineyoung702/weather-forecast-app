require 'rails_helper'

RSpec.describe ForecastCache do
  let(:zip) { Faker::Address.zip }
  let(:cache) { ForecastCache.new(zip) }
  let(:cache_key) { "forecast_#{zip}" }

  before do
    Rails.cache.clear
  end

  describe "fetch" do
    it "retrieves or stores info from the cache" do
      data = { temp: 68 }

      result = cache.fetch { data }

      expect(result).to eq(data)
      expect(Rails.cache.read(cache_key)).to eq(data)
    end

    it "returns data from cache if present" do
      cached_data = { temp: 68 }
      Rails.cache.write(cache_key, cached_data, expires_in: 30.minutes)

      new_data = { temp: 88 }
      result = cache.fetch { new_data }

      expect(result).to eq(cached_data)
      expect(Rails.cache.read(cache_key)).to eq(cached_data)
    end
  end

  describe "exists?" do
    it "returns false if zip is not cached" do
      expect(cache.exists?).to eq(false)
    end

    it "returns true if zip is cached" do
      Rails.cache.fetch(cache_key, expires_in: 30.seconds) { { temp: 68 } }
      expect(cache.exists?).to eq(true)
    end
  end
end
