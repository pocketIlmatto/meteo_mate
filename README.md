# MeteoMate

A ruby gem (currently in development - so these features are not yet available) that fetches and caches forecast data and returns point forecasts from various weather forecasting models.

## Motivation

Weather forecast data is publicly available from NOAA (and affiliates). However, accessing and maintaining a use-case specific cache of this data often requires extensive knowledge of forecasting-model output parameters, meteorology-specific field mappings and the use of esoteric tools to decode the data into more familiar formats for consumption by other software applications. Additionally, the output from the forecasting models often contains large swaths of data that are uninteresting to a wide array of use-cases.

At the same time, most of the publicly available weather forecast data services, while they might be easier to use, are not transparent with regard to the underlying source of data, do not give the user the ability to query forecast data based on the specific forecast model, and often only return basic surface weather data elements.

Finally, while there are a variety of sources of historical, current and forecasted weather available online, there aren’t many tools available to allow a user to collect only the forecasted data and current conditions needed for their specific use-cases.


## Functional Requirements
### 1 Query Spot forecast
MM supports queries for a spot forecast. For example, given a latitude, longitude, forecast model name and, optionally, max-altitude, MM returns forecasted data in json format that meets the criteria. MM returns a set of default forecasted fields (eg. temperature, wind-speed, cloud coverage, etc.).

#### 1.1 Inputs
MM requires a set of inputs in order to return forecasted data.

MM can optionally take a max altitude and returns altitude specific data in the range between surface and max altitude (in feet, MSL). By default this is be set to 18k’ MSL. In the future MM may support the querying the data via altitude ranges, max pressure, or pressure ranges.

MM validates the inputs and raises any errors prior to attempting to load the requested data.  If the time requested is not available (either via a cache hit, or on the external servers) an error is returned indicating the data is unavailable. In the future MM may support querying other online data-sources that archive model data for cache misses, but for now these queries are be limited by local cache + currently available data.

##### 1.1.1 Required
- forecast_model - string (initially MM supports GFS and HRRR)
- latitude - float (valid range is from -90 to 90 for the southern and northern hemisphere, respectively)
- longitude - float (valid range is from -180 to 180, specifying coordinates west and east of the Prime Meridian, respectively)
- time - timestamp (in UTC)

##### 1.1.2 Optional
* max_altitude - integer (feet)
The max altitude will be converted find a range of pressure levels.

#### 1.2 Output
In addition to caching the entire dataset retrieved from the forecast model source, the spot forecast query returns data in json-format. XML may be supported in future releases based on necessity.

##### 1.2.1 Default fields
The default fields returned by the query may be model specific, but in general include the following:
* Altitude specific data (Surface - max altitude)
  * Temp
  * Dew point temp
  * Wind direction (This is calculated from the U & V components of the wind)
  * Wind speed (This is calculated from the U & V components of the wind)
* Cloud cover (nebulosity)
* Precipitation rate
* Gust (surface only)
* Cloudbase (Geopotential height at cloud base level)

###### 1.2.1.1 GRIB2 Parameter mapping for default fields
::Pressure Levels::
50 mb, 75 mb, 100 mb, 125 mb, 150 mb, 175 mb, 200 mb, 225 mb, 250 mb, 275 mb, 300 mb, 325 mb, 350 mb, 375 mb, 400 mb, 425 mb, 450 mb, 475 mb, 500 mb, 525 mb, 550 mb, 575 mb, 600 mb, 625 mb, 650 mb, 675 mb, 700 mb, 725 mb, 750 mb, 775 mb, 800 mb, 825 mb, 850 mb, 875 mb, 900 mb, 925 mb, 950 mb, 975 mb, 1000 mb, 1013.2 mb
**Note:** to get data at pressure levels for the HRRR, MM uses the **wrfprs** file.

Here are some examples of ::other “levels” available:: (this list isn’t exhaustive):
surface, 2 m above ground, 10 m above ground, top of atmosphere, entire atmosphere…

Some examples of parameters combined with levels:


Parameter name | Level | GRIB2 parameter name
-------------- | ----- | --------------------
Cloud cover | entire atmosphere | :TCDC:entire atmosphere:
Precipitation rate | surface | :PRATE:surface:
Temp | surface | :TMP:surface:
Temp | 2 m above ground | :TMP:2 m above ground:
Relative humidity | 500 mb pressure | :RH:500 mb:
Dew point temp | 800 mb pressure | :DPT:800 mb:
U component | 10 m above ground | :UGRD:10 m above ground:
Gust | surface | :GUST:surface:
Cloudbase | cloud base | :HGT:cloud base:

These params are available at surface layer:
VIS, GUST, PRES, HGT, TMP, ASNOW, CNWAT, WEASD, SNOWC, SNOD, CPOFP, PRATE, APCP, WEASD, FROZR, FRZR, SSRUN, BGRUN, CSNOW, CICEP, CFRZR, CRAIN, SFCR, FRICV, SHTFL, LHTFL, GFLUX, VGTYP, CAPE, CIN, DSWRF, DLWRF, USWRF, ULWRF, VBDSF, VDDSF, HPBL, LAND, ICEC

##### 1.2.2 JSON Format
Example of MM response to a spot forecast query.  Spot forecasts for a single point in time return a single element in the ‘data’ array.
```
{
  “location”: {
    “lon”: -0.1277,
    “lat”: 51.5073
  },
  “model”: ‘HRRR’,
  “max_altitude”: 18000,
  “data”: [{
      “dt”: 1560384000,
      "nebulosity": 2.0,
      “humidity”: 72.96,
      "p_rate": 0.001,
      "p_amount": 0.01,
      “pressure”: 1013.99,
      "cloudbase": 3030,
      “levels”: [
        {
          "altitude": 2000,
          "dew_point": 290.01,
          "pressure": 942.13,
          “temperature”: 289.42,
          “wind_speed”: 2,
          “wind_direction”: 270
        },
   },...]
}
```

###### 1.2.3 Parameters
* **location**
  * **lon** geo location, longitude
  * **lat** geo location, latitude
* **model** forecast model
* **max_altitude** max altitude (MSL) used for query, ft
* **data** list of the forecasted data points, 1 element for each timestamp
  * **dtTime** of data forecasted, timestamp
  * **nebulosity** cloud coverage, %
  * **humidity** Humidity, %
  * **p_rate** Rate of precipitation, ??
  * **p_amount** Amount of precipitation for the hour
  * **pressure** Atmospheric pressure at surface, hPa
  * **temperature** Temperature at surface, K
  * **levels** for altitude specific data
    * **altitude** altitude (MSL), ft
    * **dew_point**, dew point temp, Kelvin
    * **pressure** Atmospheric pressure
    * **temperature** Temperature, K
    * **wind_speed** wind speed, meter/sec
    * **wind_direction** wind direction, degrees

### 2 Cache forecast model data
Since this tool is situated as a library to be used by other services, we leave it to the downstream service to determine what will be done with data returned from the spot queries. For this reason, MM supports a very generic and basic caching strategy. As files are downloaded, they are saved to the file-system. The top-level directory for the data in the file system can be configured system-wide and files for each forecasting model will live under a model-specific prefix.

Each model can also be configured with a file count limit which defaults to 100 files. Once the limit is reached, when a new file is placed in the cache, the oldest file (based on forecast run date) is deleted. Future versions of the tool may enable cache ejection to include pushing the file to network cold storage.

### 3 Query current conditions (future release)
MM will include support for querying current conditions in a future release.

### 4 Cache current condition data (future release)
MM will include support for caching current conditions in a future release.

### 5 Populate the cache
MM can be instrumented to populate the cache on a schedule.

#### 5.1 Inputs
* forecast_model
* time
* max_altitude

#### 5.2 Outputs
The result of populating the cache should be that MM downloads the filtered grib files for the forecast run date closest to the input time for the particular model.

### 6 Configure forecast model
MM’s model data is configurable without having to change code and build a local copy of the gem. The following data members can be modified by changing the configuration file:
* Server URL
* file format
* Run period (how often the model is run)
* Forecast period (how long each forecast period is)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'meteo_mate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install meteo_mate

This gem depends on [wgrib2](https://github.com/erget/wgrib2) being available on your system.

Installtion via custom homebrew formula:
```sh
brew install pocketilmatto/homebrew-pocket/wgrib2
```
Check the docs for installation on all other systems.

## Usage

MeteoMate is packaged as a ruby gem.

Require the library where needed (or add to your Gemfile):
```ruby
require 'meteo_mate'
```

### To configure the gem:

```ruby
MeteoMate.configure do |config|
  config.wgrib2_path = "/usr/local/bin/wgrib2"
  config.records = {
    :cloud_cover  => ":TCDC:entire atmosphere:",
    :cloud_base => ":HGT:cloud base:",
    :humidity    => ":RH:2 m above ground:",
    :gust => ":GUST:surface:",
    :precip_rate => ":PRATE:surface:",
    :pressure    => ":PRES:surface:",
    :temperature   => ":TMP:2 m above ground:",
    :ugrd  => ":UGRD:10 m above ground:",
    :vgrd  => ":VGRD:10 m above ground:"
  }
end
```

### To fetch a spot forecast:
```ruby
t = Time.now.utc # MeteoMate expects UTC time
model = MeteoMate::Model::HRRR
lat = 38.4004856
lon = -122.107524
max_altitude = 5487 # expressed in meters
forecast = MeteoMate.fetch_spot_forecast(model, time, lat, lon, max_altitude)
```

### To populate forecast data files into the cache:
```ruby
t = Time.now.utc # MeteoMate expects UTC time
model = MeteoMate::Model::HRRR
max_altitude = 5487 # expressed in meters
forecast = MeteoMate.fetch_forecast_files(model, t, max_altitude)
```

One way to populate data on a schedule is to create a cron job that executes a shell script that runs a rake task. Your mileage may vary.

First create a rake task which fetches the files for the current time:
```ruby
namespace :cache do
  desc 'Populate cache'
  task :populate, [:model, :max_altitude, :start_time] => [:environment] do |t, args|
    args.with_defaults(: max_altitude => 5487, : start_time => Time.now.utc)
    model = MeteoMate::Models::find_model(args[:model])
    forecast = MeteoMate.fetch_forecast_files(model, args[:startTime], args[:max_altitude])
  end
```

Then create a shell script that will execute this task:
```bash
#!/bin/bash
source <path to rvm>
cd <path to codebase>
RAILS_ENV=<rails environment> bundle exec rake cache:populate['HRRR']
```

Finally, edit your crontab to run the job on a schedule that makes sense for that model. It typically wouldn’t make sense to run this job more often than how often the model is run because any subsequent runs will all be cache hits.

### To fetch and read from a Grib2 file directly:
MeteoMate exposes services that can be called individually as needed.

```ruby
require 'excon'
url = "<url>" # Change this
directory = '<directory to store the file>' # Change this
filename = '<filename to use>' # Change this
lat = 37.810000 # Change this
lon = -122.000000 # Change this

MeteoMate::configure {} # Customize the configuration if desired
index_file = Excon::get("#{url}.idx").body
ranges = MeteoMate::FetchGrib2Ranges::call(index_file)
filtered_ranges = MeteoMate::FilterGrib2Ranges::call(ranges)
MeteoMate::FetchGrib2File::call(filtered_ranges, directory, filename, url)

temp = MeteoMate::ReadGrib2File::call(File.join(hrrr.cache_directory, hrrr.filename), :temp, latitude: lat, longitude: lon)
```

## References
- [Diagnostic output fields for RAP/HRRR](https://rapidrefresh.noaa.gov/RAP_var_diagnosis.html)
- [wgrib2](https://www.cpc.ncep.noaa.gov/products/wesley/wgrib2/index.html)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/meteo_mate. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Thanks to
This gem is expanding on some of the ideas and work done in https://github.com/vinc/forecaster to include multiple models, a  configurable caching strategy, and abstractions for fetching data at various altitudes.
