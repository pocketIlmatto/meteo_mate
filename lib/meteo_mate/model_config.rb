require 'yaml'
module MeteoMate

  class ModelConfig

    def initialize(model)
      @config = ModelConfig::read_config_file(model)
    end

    def cache_directory
      @config['cache_directory']
    end

    def filename_format
      @config['filename_format']
    end

    def forecast_interval
      @config['forecast_interval']
    end

    def run_interval
      @config['run_interval']
    end

    def server_url
      @config['server_url']
    end

    def subdir_format
      @config['subdir_format']
    end

    def self.read_config_file(model)
      YAML.load(
        File.open(File.join(File.dirname(__FILE__),
          "../../config/#{model}.yaml")).read
      )
    end

  end

end