require 'spec_helper'
require 'time'

RSpec.describe MeteoMate::ForecastModel do
  let(:valid_intervals) { [24, 12, 8, 6, 4, 3, 2, 1] }
  let(:model_config) { FakeModelConfig.new }
  let(:now) { Time.now.utc }

  class FakeModelConfig
    def initialize
    end

    def cache_directory
    end

    def filename_format
    end

    def forecast_interval
    end

    def run_interval
    end

    def server_url
    end

    def subdir_format
    end
  end

  before do
    allow(model_config).to receive(:cache_directory).and_return(Faker::File.dir)
    allow(model_config).to receive(:filename_format).and_return("%02d%03d")
    allow(model_config).to receive(:forecast_interval)
      .and_return(valid_intervals.sample)
    allow(model_config).to receive(:run_interval)
      .and_return(valid_intervals.sample)
    allow(model_config).to receive(:server_url).and_return(Faker::Internet.url)
    allow(model_config).to receive(:subdir_format)
      .and_return("%04d%02d%02d/%02d")
  end

  describe 'file utilities' do
    let(:forecast_hour_num) { rand(383) + 1 }
    let(:model) { MeteoMate::ForecastModel.new(model_config, Time.now.utc) }
    let(:run_hour) { valid_intervals.sample }
    let(:run_time) { DateTime.parse(now.strftime(
      "%Y-%m-%dT00:#{run_hour.to_s.rjust(2, '0')}:00%z")) }
    let(:sub_directory) { Faker::File.dir }

    before do
      allow(model).to receive(:run_hour).and_return(run_hour)
      allow(model).to receive(:run_time).and_return(run_time)
      allow(model).to receive(:forecast_hour_num)
        .and_return(forecast_hour_num)
    end

    it 'should format the cache directory with the correct parameters' do
      expect(model).to receive(:sub_directory).and_return(sub_directory)
      expect(model.cache_directory).to eql(
        File.join(model_config.cache_directory, sub_directory))
    end

    it 'should format the sub_directory with the correct parameters' do
      expect(model.sub_directory).to eql(format(model_config.subdir_format,
        run_time.year, run_time.month, run_time.day, run_hour))
    end

    it 'should format the filename with the correct parameters' do
      expect(model.filename).to eql(format(model_config.filename_format,
        run_hour, forecast_hour_num))
    end

    it 'should format the url with the correct parameters' do
      filename = Faker::File.file_name
      expect(model).to receive(:filename).and_return(filename)
      expect(model).to receive(:sub_directory).and_return(sub_directory)
      expect(model.url).to eql(format("%s/%s/%s", model_config.server_url,
        sub_directory, filename))
    end
  end

  describe 'forecast time calculations' do
    let(:model) { MeteoMate::ForecastModel.new(model_config, time) }
    let(:time) { Time.now.utc }

    describe 'forecast_hour_num' do
      before do
        expect(model).to receive(:run_time).and_return(time)
      end

      it 'should calculate the correct forecast hour' do
        add_hours = rand(5) + 1

        expect(model).to receive(:forecast_time)
          .and_return(time + add_hours * 3600)

        expect(model.forecast_hour_num).to eql(add_hours)
      end

      it 'should raise if the requested forecast is too far in the future' do
        add_hours = MeteoMate::ForecastModel::FORECAST_HOUR_LIMIT + 1

        expect(model).to receive(:forecast_time)
          .and_return(time + add_hours * 3600)

        expect { model.forecast_hour_num }.to raise_error('Too far in the future')
      end
    end

    describe 'forecast_time' do
      it 'should return the closest forecast time based on the interval' do
        forecast_time = model.forecast_time

        expect(forecast_time.hour)
          .to eql((time.hour/model_config.forecast_interval) *
            model_config.forecast_interval)
      end
    end
  end

  describe 'run_time' do
    it 'returns the next to last run time if requested time is in the ' +
      'future' do
      time = Time.now.utc + model_config.run_interval * 3600

      model = MeteoMate::ForecastModel.new(model_config, time)
      expect(model).to receive(:get_next_to_last_run).and_return(time)
      expect(model.run_time).to eql(time)
    end

    it 'returns the closest run time if the requested time is in the past' do
      time = Time.now.utc - model_config.run_interval * 3600
      model = MeteoMate::ForecastModel.new(model_config, time)

      run_time = model.run_time
      expect(run_time).to be <= time
      expect((time.hour - run_time.hour)).to be <= model_config.run_interval
      expect(run_time.hour % model_config.run_interval).to be 0
    end
  end
end
