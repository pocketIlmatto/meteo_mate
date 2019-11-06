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

  def self.get_filename(model, time)
    config = MeteoMate::config(model)
    run_time = MeteoMate::get_run_time(time, config.run_interval)

    fct_hour = MeteoMate::get_forecast_hour_num(time, run_time,
      config.forecast_interval)
    format(config.filename_format, run_time.hour, fct_hour)
  end

  # Returns the next to last run time if the requested time after it.
  # Otherwise, finds the closest run time based on the run interval.
  def self.get_run_time(time, run_interval)
    next_to_last_run = MeteoMate::get_next_to_last_run(run_interval)
    return next_to_last_run if time > next_to_last_run

    Time.utc(time.year, time.month, time.day,
      (time.hour / run_interval) * run_interval)
  end

  # Find the closest forecast time based on the model's forecast interval.
  # Eg: We want the forecast for 2019-12-24 21:03:00, and the forecast interval
  # is 6. This would return 2019-12-24 18:00:00. Here we take advantage of
  # integer division rounding down.
  def self.get_forecast_time(time, forecast_interval)
    Time.utc(time.year, time.month, time.day,
      (time.hour / forecast_interval) * forecast_interval)
  end

  # Calls #get_forecast_time first, then calculates the number of hours between
  # the given runtime and this forecast time to get the forecast hour num.
  # Eg. if Run Time is 2019-12-23 10:00:00 and forecast time is
  # 2019-12-24 10:00:00, forecast hour would be 24
  def self.get_forecast_hour_num(time, run_time, forecast_interval)
    forecast_time = MeteoMate::get_forecast_time(time, forecast_interval)
    ((forecast_time - run_time)/3600).to_i
  end

  # We use the next-to-last run since it can take a number of hours before a
  # forecast run data file is available online.
  def self.get_next_to_last_run(run_interval)
    now = Time.now.utc
    run = Time.utc(now.year, now.month, now.day,
      (now.hour / run_interval) * run_interval)

    run - run_interval * 3600
  end

end
