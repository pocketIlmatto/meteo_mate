require 'meteo_mate/fetch_grib2_ranges'
require 'meteo_mate/forecast_model'
require 'meteo_mate/model_config'
require 'meteo_mate/version'

module MeteoMate

  def self.model_config(model)
    MeteoMate::ModelConfig.new(model)
  end

  def self.forecast_model(model)
    MeteoMate::ForecastModel.new(MeteoMate::model_config(model))
  end

  def self.fetch_spot_forecast(model, time, lat, lon)
  end

  def self.fetch_forecast_files(model, time)
  end

end
