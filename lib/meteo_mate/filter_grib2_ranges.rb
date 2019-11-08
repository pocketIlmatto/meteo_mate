module MeteoMate

  class FilterGrib2Ranges

    def self.call(ranges, desired_ranges = [])
      if desired_ranges.empty?
        desired_ranges = MeteoMate.configuration.records.values
      end
      desired_ranges.map { |k| ranges[k] }.compact!
    end

  end

end