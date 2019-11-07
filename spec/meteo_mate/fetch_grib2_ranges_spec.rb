require 'spec_helper'

RSpec.describe MeteoMate::FetchGrib2Ranges do
  let(:idx_file) {
    File.open("#{RSPEC_ROOT}/spec_resources/grib2_index_file.idx")
  }

  it 'should parse the ranges from the file' do
    ranges = MeteoMate::FetchGrib2Ranges::call(idx_file)
    expect(ranges.size).to eql(522)
    expect(ranges[":CIN:surface:"]).to eql([230325218, 230633113])
  end

end