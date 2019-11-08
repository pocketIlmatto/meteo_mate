module MeteoMate

  class FilterGrib2Ranges

    def self.call(ranges, desired_records = [])
      if desired_records.empty?
        desired_records = MeteoMate.configuration.records.values
      end
      records = desired_records.map { |k| ranges[k] }
      records.compact!
      records
    end

  end

end