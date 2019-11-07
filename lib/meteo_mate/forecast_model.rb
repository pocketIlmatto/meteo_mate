require_relative 'model_config'

module MeteoMate
  class ForecastModel

    module Name
      HRRR = 'hrrr'
      GFS = 'gfs'
    end

    FORECAST_HOUR_LIMIT = 384

    def initialize(config, time = Time.now.utc)
      @config = config
      @time = time
    end

    def cache_directory
      @cache_directory ||= File.join(@config.cache_directory, sub_directory)
    end

    def filename
      @filename ||= format(@config.filename_format, run_hour, forecast_hour_num)
    end

    def forecast_hour_num
      @forecast_hour_num ||= get_forecast_hour_num
    end

    def forecast_time
      @forecast_time ||= get_forecast_time
    end

    def next_to_last_run
      @next_to_last_run ||= get_next_to_last_run
    end

    def run_hour
      @run_hour ||= run_time.hour
    end

    def run_time
      @run_time ||= get_run_time
    end

    def sub_directory
      @sub_directory ||= format(@config.subdir_format, run_time.year,
        run_time.month, run_time.day, run_hour)
    end

    def url
      @url ||= format("%s/%s/%s", @config.server_url, sub_directory, filename)
    end

  private

    def forecast_interval
      @config.forecast_interval
    end

    # Calls #get_forecast_time first, then calculates the number of hours between
    # the given runtime and this forecast time to get the forecast hour num.
    # Eg. if Run Time is 2019-12-23 10:00:00 and forecast time is
    # 2019-12-24 10:00:00, forecast hour would be 24
    def get_forecast_hour_num
      fct_hour = ((forecast_time - run_time)/3600).to_i
      raise 'Too far in the future' if fct_hour > FORECAST_HOUR_LIMIT
      fct_hour
    end

    # Find the closest forecast time based on the model's forecast interval.
    # Eg: We want the forecast for 2019-12-24 21:03:00, and the forecast interval
    # is 6. This would return 2019-12-24 18:00:00. Here we take advantage of
    # integer division rounding down.
    def get_forecast_time
      Time.utc(@time.year, @time.month, @time.day,
        (@time.hour / forecast_interval) * forecast_interval)
    end

    # We use the next-to-last run since it can take a number of hours before a
    # forecast run data file is available online.
    def get_next_to_last_run
      now = Time.now.utc
      run = Time.utc(now.year, now.month, now.day,
        (now.hour / run_interval) * run_interval)

      run - run_interval * 3600
    end

    # Returns the next to last run time if the requested time after it.
    # Otherwise, finds the closest run time based on the run interval.
    def get_run_time
      return next_to_last_run if @time >= next_to_last_run

      Time.utc(@time.year, @time.month, @time.day,
        (@time.hour / run_interval) * run_interval)
    end

    def run_interval
      @config.run_interval
    end

  end
end