RSpec.describe MeteoMate do
  it "has a version number" do
    expect(MeteoMate::VERSION).not_to be nil
  end

  it "fetches a config" do
    expect(MeteoMate::config(MeteoMate::Model::HRRR)).to be_a MeteoMate::Config
  end

  it "returns the closest run time to passed in date" do
    # TODO: this test will be flaky if the run date is not the same as current
    # date. Fix and make it more robust.
    time = Time.now.utc
    run_time = Time.utc(time.year, time.month, time.day, time.hour - 1)

    expect(MeteoMate::get_closest_run_time(time, 1, 1)).to eql(run_time)
  end

  it "returns the correct forecast hour" do
    add_hours = rand(5)
    time = Time.now.utc

    forecast_time = Time.utc(time.year, time.month, time.day,
      time.hour - 1 + add_hours)
    run_time = Time.utc(time.year, time.month, time.day, time.hour - 1)

    expect(MeteoMate::get_forecast_hour(forecast_time, run_time))
      .to eql(add_hours)
  end
end
