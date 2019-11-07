require 'fileutils'
require 'spec_helper'
require 'tmpdir'

RSpec.describe MeteoMate::FetchGrib2File do
  let(:filename) { Faker::File.file_name }
  let(:ranges) { {"key1": [1, 1000], "key2": [3000, 5000] } }
  let(:tmp_dir) { Dir.mktmpdir }
  let(:url) { Faker::Internet.url }

  after do
    FileUtils.remove_entry_secure(tmp_dir)
  end

  it 'should pass the byte-range header to Excon' do
    byte_ranges = ranges.map { |r| r.join("-") }.join(",")
    expect(Excon).to receive(:get).with(url,
      {headers: {"Range" => "bytes=#{byte_ranges}"}, response_block: anything})

    MeteoMate::FetchGrib2File::call(ranges, tmp_dir, filename, url)
  end

end