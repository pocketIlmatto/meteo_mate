# require 'meteo_mate/configuration'
# require 'meteo_mate/fetch_grib2_file'
# require 'meteo_mate/fetch_grib2_ranges'
# require 'meteo_mate/filter_grib2_ranges'
# require 'meteo_mate/forecast_model'
# require 'meteo_mate/model_config'
# require 'meteo_mate/'
# require 'meteo_mate/version'

Dir[File.join(__dir__, 'meteo_mate', '*.rb')].each { |file| require file }

module MeteoMate
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= MeteoMate::Configuration.new
    yield(configuration)
  end

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
