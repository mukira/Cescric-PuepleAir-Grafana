# Purple Air Exporter
A Prometheus extractor for PurpleAir sensor data using the PurpleAir API. This script queries the PurpleAir API (api.purpleair.com) for public sensor(s) and captures the data as Prometheus metrics. Most other implementations of similar extractors I found for PurpleAir were not very configurable and/or using outdated methods of gathering this data (the old /json endpoint was shut down in 2022, and the map.purpleair.com method which feels like a hack). Additionally, the official API offers an endpoint to query data from multiple sensors in a single request.

[![Docker Image Version](https://img.shields.io/docker/v/nirajsanghvi/purpleair_exporter?sort=semver)][hub]
[![Docker Image Size](https://img.shields.io/docker/image-size/nirajsanghvi/purpleair_exporter)][hub]

[hub]: https://hub.docker.com/r/nirajsanghvi/purpleair_exporter/

The following fields are mapped directly from the API response (with each field containing the `sensor_id` and `name` attached as `label`):
- `last_seen` -> `purpleair_last_seen_seconds`
- `pm2.5` -> `purpleair_pm2_5`
- `pm2.5_10minute` -> `purpleair_pm2_5_10_minute`
- `pm10.0` -> `purpleair_pm10_0`
- `temperature` -> `purpleair_temp_f`
- `pressure` -> `purpleair_pressure`
- `humidity` -> `purpleair_humidity`

Additionally, the AQI is computed for PM2.5 (both from the instant value and the 10-minute average) using this US EPA formula to roughly match what is shown on the PurpleAir map (for whatever reason, the API does not provide this calculation in its response): https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877. The AQI values also are computed using the AQandU conversion as well, and you can use the `conversion` label as a filter depending on whether you want to use that (`conversion="AQandU"`) or not (`conversion="None"`)
- `purpleair_aqi_pm2_5`
- `purpleair_aqi_pm2_5_10_minute`
- `purpleair_aqi_pm10_0`

## Configuration
The following environment variables are used by this script:

### `PAE_SENSOR_IDS` (required)
A comma-separated list of sensor IDs to collect data from. Sensor IDs for public sensors can be found on the [PurpleAir map](https://map.purpleair.com) by clicking on the sensor and viewing the widget code, which should contain a 5 or 6-digit number representing the sensor.

### `PAE_API_READ_KEY` (required)
As a relatively new option, you can visit https://develop.purpleair.com/keys to generate API keys. This script only requires the READ key, not the WRITE one since it is only reading sensor data. Note: That website only offers a Google login option, so if you don't want to do that you might have luck trying the older method of simply sending an email to contact@purpleair.com with your first name, last name, and email address to assign them to.

### `PAE_RUN_INTERVAL_S` (optional)
The default setting is for the PurpleAir API to be called to update metrics every 120 seconds. This is inline with the [API usage guidelines](https://community.purpleair.com/t/api-use-guidelines/1589):
>PurpleAir sensors report data every two minutes. This means that it may not be necessary to query data faster than every minute with the real-time API.

The main intent of making this configurable was to be able to ping the API less frequently if your Prometheus job does not need data that frequently.

### `PAE_LOGGING` (optional)
Log level of the script, defaults to 'info', accepts any [Python logging level name](https://docs.python.org/3/howto/logging.html#logging-levels)

### `PAE_PROM_PORT` (optional)
The port to run the Prometheus HTTP server on, defaults to 9101

## Docker CLI

Find this on [Docker Hub](https://hub.docker.com/r/nirajsanghvi/purpleair_exporter)

```
docker run -d \
  --name=purpleair_exporter \
  -p 9101:9101 \
  -e PAE_SENSOR_IDS=<sensor1>,<sensor2>,<sensor3> \
  -e PAE_API_READ_KEY=<PurpleAir API Read Key> \
  --restart unless-stopped \
  nirajsanghvi/purpleair_exporter
```

## Docker Compose

```yaml
version: '3.9'
services:
  purpleair-exporter:
    image: nirajsanghvi/purpleair_exporter:latest
    environment:
      - 'PAE_SENSOR_IDS=<sensor1>,<sensor2>,<sensor3>'
      - 'PAE_API_READ_KEY=<PurpleAir API Read Key>'
    container_name: PurpleAir_Exporter
    hostname: purpleair_exporter
    ports:
      - 9101:9101
    restart: on-failure:5
```

## Grafana Dashboard
A sample Grafana dashboard (pictured below) is included in this repository: https://github.com/nirajsanghvi/purpleair_exporter/blob/main/grafana_sample.json

![purpleair_extractor_grafana](https://user-images.githubusercontent.com/4184922/232413977-5a489add-e546-4c26-ba1b-9cdafa80b8c8.png)


## LICENSE

MIT. See `LICENSE`.

    Copyright (c) 2024 Mukira Gitonga
    mukiragitonga@gmail.com
    
## Credits
This project was heavily influenced by the structure of Nick Pegg's [purple_air_scraper](https://github.com/nickpegg/purple_air_scraper), as well as multiple PurpleAir forum posts (cited as comments in the script).
