module MeteoMate

  class FetchGrib2Ranges

    # index_file: a .idx file of a GRIB2 file containing forecast data
    # returns: hashmap of every record in the file with byte ranges.
    def self.call(index_file)
      ranges = {}
      lines = index_file.lines.map { |line| line.split(":") }
      lines.each_with_index do |line, i|

        # Key is made up of :<parameter>:<level>:. Eg. :PRATE:surface:
        key = ":#{line[3]}:#{line[4]}:"

        # The second field in the line is the first byte of the record in the
        # GRIB2 file
        ranges[key] = [line[1].to_i]

        next_line = lines[i + 1]
        ranges[key] << next_line[1].to_i - 1 if next_line
      end
      ranges
    end

  end

end