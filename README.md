# Purple Air Scraper
A Prometheus extractor for PurpleAir sensor data using the PurpleAir API. This script queries the PurpleAir API (api.purpleair.com) for public sensor(s) and captures the data as Prometheus metrics. Most other implementations of similar extractors I found were using outdated methods of gathering this data (the old /json endpoint was shut down in 2022, and the map.purpleair.com method feels like a hack. Additionally, the official API offers an endpoint to query multiple sensors in a single request.

The following fields are mapped directly from the API response:
- `name`
- `last_seen`
- `pm2.5`
- `pm2.5_10minute`
- `pm10.0`
- `temperature`
- `pressure`
- `humidity`

Additionally, the AQI is computed for PM2.5 (both from the instant value and the 10-minute average) using this US EPA formula to roughly match what is shown on the PurpleAir map (for some reason the API does not provide this calculation in its response): https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877. The AQI values also are computed using the AQandU conversion as well, and you can use the `conversion` label as a filter depending on whether you want to use that (`conversion="AQandU"`) or not (`conversion="None"`)

## Configuration
The following environment variables are used by this script:

### `PAS_SENSOR_IDS` (required)
A comma-separated list of sensor IDs to collect data from. Sensor IDs for public sensors can be found on the [PurpleAir map](https://map.purpleair.com) by clicking on the sensor and viewing the widget code, which should contain a 5 or 6-digit number representing the sensor.

### `PAS_API_READ_KEY` (required)
As a relatively new option, you can visit https://develop.purpleair.com/keys to generate API keys. This script only requires the READ key, not the WRITE one since it is only reading sensor data. Note: That website only offers a Google login option, so if you don't want to do that you might have luck trying the older method of simply sending an email to contact@purpleair.com with your first name, last name, and email address to assign them to.

### `PAS_LOGGING`
Log level of the script, defaults to 'info', accepts any [Python logging level name](https://docs.python.org/3/howto/logging.html#logging-levels)

### `PAS_PROM_PORT`
The port to run the Prometheus HTTP server on, defaults to 9101
