# Weather Forecast App
This Ruby on Rails app allows a user to provide a US address and retrieve the current temperature and future temperature predictions.

## Features
- Accepts a user's input of a US address
- Determines address coordinates using the [Geocoder](https://github.com/alexreisner/geocoder) gem
- Retrieves weather forecast data using the [Open-Meteo API](https://open-meteo.com/)
- Displays the verified address, coordinates, current temperature, and 7-day weather forecast
- Caches the forecast details for 30 minutes based on zip code
- Indicates whether data is cached
- Implements error handling and logging

## Installation
```
git clone tbd
cd tbd
bundle install
rails s
```

## Usage
1. Open http://localhost:3000 in your browser
2. Enter a United States address
3. Click `Get Forecast`
4. If address is found, you will see a display with the verified address, coordinates, current temperature, and a 7-day forecast. Additionally, you'll see a note on whether the information was saved and pulled from the cache or if it was new data.
5. If address is invalid or an error occurs, you will be rerouted to the home page and asked to provide a different address

## Technologies
- Ruby on Rails
- Geocoder
- Open-Meteo API
- RSpec and Webmock

## Potential Improvements 
- add address autocomplete dropdown/Address Autocomplete API - maybe Google Maps Place API
- add weather for user's current location
- utilize an async worker to update cache - maybe sidekiq
- utilize sidekiq for API calls for retry capability


