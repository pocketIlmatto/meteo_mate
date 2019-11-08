require 'excon'
require 'fileutils'

module MeteoMate

  class FetchGrib2File

    def self.call(ranges, directory, filename, url)
      raise "No ranges specified" if ranges.nil? || ranges.empty?

      FileUtils.mkpath(directory)
      path = File.join(directory, filename)

      streamer = lambda do |chunk, remaining, total|
        File.open(path, "ab") { |f| f.write(chunk) }
      end

      byte_ranges = ranges.map { |r| r.join("-") }.join(",")
      headers = { "Range" => "bytes=#{byte_ranges}" }

      begin
        Excon.get(url, headers: headers, response_block: streamer)
      rescue Excon::Errors::Error => e
        File.delete(path)
        raise "Download failed for: #{url}. Error: #{e}"
      end
    end
  end

end