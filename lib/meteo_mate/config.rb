require 'yaml'
module MeteoMate

  class Config

    def initialize(model)
      @config = Config::read_config_file(model)
    end

    def forecast_period
      @config['forecast_period']
    end

    def run_interval
      @config['run_interval']
    end

    def server_url
      @config['server_url']
    end

    def self.read_config_file(model)
      YAML.load(
        File.open(File.join(File.dirname(__FILE__),
          "../../config/#{model}.yaml")).read
      )
    end

  end

end