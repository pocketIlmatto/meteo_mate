require 'spec_helper'
require 'time'

RSpec.describe MeteoMate do
  let(:valid_intervals) { [24, 12, 8, 6, 4, 3, 2, 1] }

  it "has a version number" do
    expect(MeteoMate::VERSION).not_to be nil
  end

  it "fetches a config" do
    expect(MeteoMate::config(MeteoMate::Model::HRRR)).to be_a MeteoMate::Config
  end

  describe '#get_filename' do
    it 'should format the filename' do
      run_time = MeteoMate::get_next_to_last_run(valid_intervals.sample)
      fct_hour = rand(300) + 1
      model = MeteoMate::Model::HRRR
      filename_format = "%02d%03d"

      expect(MeteoMate).to receive(:get_run_time).and_return(run_time)
      expect(MeteoMate).to receive(:get_forecast_hour_num).and_return(fct_hour)
      expect_any_instance_of(MeteoMate::Config).to receive(:filename_format)
        .and_return(filename_format)

      expect(MeteoMate::get_filename(model, Time.now.utc))
        .to eql(format(filename_format, run_time.hour, fct_hour))
    end

    context 'when the model is HRRR' do
      it 'should return the correct filename for dates in the past' do
        time = Time.now.utc - (rand(24) + 2) * 3600

        t = time.hour.to_s.rjust(2, "0")
        expect(MeteoMate::get_filename(MeteoMate::Model::HRRR, time))
          .to eql("hrrr.t#{t}z.wrfnatf00.grib2")
      end

      it 'should return the correct filename for dates in the future' do
        time = Time.now.utc + (rand(24) + 2) * 3600

        run_time = MeteoMate::get_next_to_last_run(1)
        fct_hour = ((time - run_time)/3600).to_i.to_s.rjust(2, "0")
        t = run_time.hour.to_s.rjust(2, "0")

        expect(MeteoMate::get_filename(MeteoMate::Model::HRRR, time))
          .to eql("hrrr.t#{t}z.wrfnatf#{fct_hour}.grib2")
      end
    end

    context 'when the model is GFS' do
      it 'should return the correct filename for dates in the past' do
        time = Time.now.utc - (rand(24) + 2) * 3600

        run_time = MeteoMate::get_run_time(time, 6)
        t = run_time.hour.to_s.rjust(2, "0")
        fct_hour = MeteoMate::get_forecast_hour_num(time, run_time, 3)
        f = fct_hour.to_s.rjust(3, "0")

        expect(MeteoMate::get_filename(MeteoMate::Model::GFS, time))
          .to eql("gfs.t#{t}z.pgrb2.0p25.f#{f}")
      end

      it 'should return the correct filename for dates in the future' do
        time = Time.now.utc + (rand(24) + 2) * 3600

        run_time = MeteoMate::get_next_to_last_run(6)
        t = run_time.hour.to_s.rjust(2, "0")
        fct_hour = MeteoMate::get_forecast_hour_num(time, run_time, 3)
        f = fct_hour.to_s.rjust(3, "0")

        expect(MeteoMate::get_filename(MeteoMate::Model::GFS, time))
          .to eql("gfs.t#{t}z.pgrb2.0p25.f#{f}")
      end
    end
  end

  describe '#get_forecast_time' do
    let(:forecast_interval) { valid_intervals.sample }

    it 'should return the closest forecast time based on the interval' do
      time = Time.now.utc

      forecast_time = MeteoMate::get_forecast_time(time, forecast_interval)
      expect(forecast_time.hour)
        .to eql((time.hour/forecast_interval) * forecast_interval)
    end
  end

  describe '#get_forecast_hour_num' do
    let(:forecast_interval) { valid_intervals.sample }

    it "returns the correct forecast hour number" do
      add_hours = rand(5) + 1
      time = Time.now.utc
      # Prevent pushing the forecast time into the next day to simplify testing
      time -= add_hours * 3600 if time.hour + add_hours >= 24

      # For testing simplicity, stub the call to get the forecast time
      forecast_time = Time.utc(time.year, time.month, time.day,
        time.hour + add_hours)
      expect(MeteoMate).to receive(:get_forecast_time)
        .with(forecast_time, forecast_interval).and_return(forecast_time)

      run_time = Time.utc(time.year, time.month, time.day, time.hour)

      expect(MeteoMate::get_forecast_hour_num(forecast_time, run_time,
        forecast_interval)).to eql(add_hours)
    end
  end

  describe '#get_run_time' do
    [24, 12, 8, 6, 4, 3, 2, 1].each do |run_interval|
      context "when run_interval is #{run_interval}" do
        it "returns the next to last run time if requested time is in the future" do
          time = Time.now.utc + 3600

          expected_run_time = MeteoMate::get_next_to_last_run(run_interval)
          expect(MeteoMate::get_run_time(time, run_interval))
            .to eql(expected_run_time)
        end

        it "returns the closest run time if the requested time is in the past" do
          time = Time.now.utc - run_interval * 3600

          run_time = MeteoMate::get_run_time(time, run_interval)
          expect(run_time).to be <= time
          expect((time.hour - run_time.hour)).to be <= run_interval
          expect(run_time.hour % run_interval).to be 0
        end
      end
    end
  end
end
