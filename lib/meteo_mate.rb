require 'meteo_mate/config'
require 'meteo_mate/version'

module MeteoMate

  module Model

    HRRR = 'hrrr'
    GFS = 'gfs'

  end

  def self.config(model)
    MeteoMate::Config.new(model)
  end

  def self.fetch_spot_forecast(model, time, lat, lon)
  end

  def self.fetch_forecast_files(model, time)
  end

  def self.get_closest_run_time(time, forecast_period, run_period)
    forecast_time = MeteoMate::get_forecast_time(time, forecast_period)

    run_time = Time.utc(time.year, time.month, time.day,
      (time.hour / run_period) * run_period)
    run_time -= run_period * 3600 if run_time == forecast_time

    run_time
  end

  def self.get_forecast_time(time, forecast_period)
    Time.utc(time.year, time.month, time.day,
      (time.hour / forecast_period) * forecast_period)
  end

  def self.get_forecast_hour(forecast_time, run_time)
    ((forecast_time - run_time)/3600).to_i
  end

end
