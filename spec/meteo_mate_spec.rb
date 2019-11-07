require 'spec_helper'
require 'time'

RSpec.describe MeteoMate do
  let(:valid_intervals) { [24, 12, 8, 6, 4, 3, 2, 1] }

  it "has a version number" do
    expect(MeteoMate::VERSION).not_to be nil
  end

  it "fetches a config" do
    expect(MeteoMate::model_config(MeteoMate::ForecastModel::Name::HRRR))
      .to be_a MeteoMate::ModelConfig
  end

end
