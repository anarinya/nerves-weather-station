# Weather Station

**Status:** proof-of-concept, development/local environment only

**ToDo:** tests, liveview dashboard, security for running in production, externalizing config

# Description

![image](https://github.com/anarinya/nerves-weather-station/assets/5115364/1ea06687-3aa8-48f0-b287-7cd5bb4fe47a)


This is a small experimental Nerves project to make a small weather station and display the summarized readings over time. It contains the two following projects:

### Sensor Hub

- This contains the nerves firmware and located within the `sensor_hub` directory. It uses the `publisher` and `veml6030` directories as dependencies.
- The `publisher` project handles starting up a supervisor that monitors the sensors and schedules publishing/posting sensor readings to the dashboard `/weather-conditions` endpoint. Additionally, it normalizes all sensor readings so measurements can be taken the same way, regardless of how interacting with a specific sensor differs behind the scenes.
- The `veml6030` project is a custom sensor-to-elixir mapping for all readings and actions that can be taken on the sensor. The other two sensors used in this project use external dependencies instead of this method.

### Dashboard

- This is a phoenix liveview project that has both a publishing endpoint used for sensor hub readings, as well as a work-in-progress dashboard to display available sensor readings.

# Dashboard

## Setup

Install dependencies after navigating into the dashboard directory:

```elixir
$ mix deps.get
```

Run docker compose to create the Postgres Timeseries DB and setup Grafana on port 3000:

```elixir
$ docker-compose up -d
```

Create database tables by running available migrations:

```elixir
$ mix ecto.create
$ mix.ecto.migrate
```

Start the server. It will run on port 4000 and accept incoming POST requests to /weather-conditions on a LAN:

```elixir
$ mix phx.server
```

To setup Grafana, visit http://localhost:3000 and import the JSON file located at `grafana/weather-tracker.json`. Data will not yet be available until the service is running and the sensor hub is successfully setup and starts publishing data.

**Note**: This is a work in progress and there is no visualization dashboard just yet. The initial version of this project just uses Grafana to visualize available data.

# Sensor Hub

## Hardware Requirements

This project has been created to work with the following:

- Raspberry Pi
- SparkFun Qwiic sensors + Hat
    - VEML6030 - Ambient light sensor
    - SGP40 - Air Quality Sensor
    - BME680 - Air Quality Sensor
- MicroSD Card

### Hardware Setup

- Connect Qwiic Hat to Raspberry Pi, and sensors via Qwiic cables to Hat on Raspberry Pi.
- Plug in MicroSD card to Raspberry Pi
- Connect USB cable to computer

## Firmware Setup

Modify the `:sensor_hub, :weather_tracker_url` value in `sensor_hub/config/target.exs` to point to the location of the `/weather-conditions` endpoint running from the dashboard project.

```elixir
config :sensor_hub, :weather_tracker_url, "http://192.168.1.187:4000/api/weather-conditions"
```

Export a MIX_TARGET environment variable, set to the iteration of RaspberryPi or other device the sensor hub will be used on:

```bash
$ export MIX_TARGET=rpi4
```

Navigate into the sensor_hub directory, build firmware and then upload it:

```bash
$ mix firmware
$ mix upload hub.local
```

Confirm the elixir shell is accessible on the device:

```bash
$ ssh hub.local
```

When SSH is successful and the elixir shell is available, VintageNet may need to be configured with local LAN details so it can be accessed via that instead of USB:
```elixir
iex> 
VintageNet.configure("wlan0", %{
  type: VintageNetWiFi,
  vintage_net_wifi: %{
    networks: [%{
      key_mgmt: :wpa_psk,
      ssid: "<YOUR NETWORK NAME>",
      psk: "<YOUR WIRELESS PASSWORD>"
    }]
  },
  ipv4: %{method: :dhcp}
})
```


**Note:** If any messages about SSH keys pop up, follow the instructions given. By default, the firmware installation may expect the device to be located at nerves.local instead of hub.local. After connecting at least once via SSH, this seems to update.

Once connected, debug logging can be viewed:

```elixir
iex> RingLogger.attach()
```

As soon as the firmware has been uploaded to the device, the supervisor should kick off the publisher and sensor readings, which will immediately start publishing to the dashboard backend every 10 seconds.

```mermaid
graph LR
	PG[("⏲\nPostgresDB\n[TimeseriesDB]\n\n")]
	QwiicHAT["Qwiic\nHAT\n\n"]

  subgraph RPI4["Raspberry Pi"]
		subgraph "Sensor Hub Firmware"
			subgraph Supervisor
				Publisher
				SensorSpecs
			end
		end
	end


	subgraph Dashboard["Dashboard Service"]
		Endpoint["POST /weather-conditions"]
    DL["Dashboard\nLiveView"]
    Endpoint --> |publish| PubSub
    DL --> |subscribe| PubSub
	end

QwiicHAT --> RPI4
VEML6030 --> QwiicHAT
SGP40 --> QwiicHAT
BME680 --> QwiicHAT
Publisher --> LAN
LAN --> Endpoint

Endpoint --> PG
PG --> Grafana
User --> Grafana
U2["User"] --> DL
```
