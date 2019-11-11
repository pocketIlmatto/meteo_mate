module MeteoMate

  class ReadGrib2File

    def self.call(path, record_key, latitude: 0.0, longitude: 0.0)
      raise "#{path} not found" unless File.exist?(path)

      wgrib2 = MeteoMate.configuration.wgrib2_path
      record = MeteoMate.configuration.records[record_key]
      coordinates = "#{longitude} #{latitude}"

      output = `#{wgrib2} #{path} -lon #{coordinates} -match "#{record}"`
      return if output.empty?
      # sample output:
      # "2:120674:lon=237.750000,lat=37.750000,val=282.829\n
      # 5:1679032:lon=237.750000,lat=37.750000,val=282.829\n"
      fields = output.split("\n").first.split(":")
      params = Hash[*fields.last.split(",").map { |s| s.split("=")}.flatten]

      params["val"]
    end

  end

end