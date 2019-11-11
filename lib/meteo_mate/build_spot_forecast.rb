require_relative 'conversions'

module MeteoMate

  class BuildSpotForecast
    extend MeteoMate::Conversions

    def self.call(path, time, latitude, longitude)
      data = {}

      data[:date] = time.localtime.strftime("%Y-%m-%d")
      data[:time] = time.localtime.strftime("%T")

      MeteoMate.configuration.records.keys.each do |record_key|
        data[record_key] =  MeteoMate::ReadGrib2File::call(path, record_key,
          latitude: latitude, longitude: longitude).to_f
      end
      return {location: {lat: latitude, lon: longitude},
        data: BuildSpotForecast.convert_data(data)}
    end

    def self.convert_data(data)
      data[:temp] = BuildSpotForecast.temp_k_to_c(data[:temp]) if data[:temp]
      if data[:ugrd] && data[:vgrd]
        data[:wind_direction] = BuildSpotForecast.wind_direction(data[:ugrd],
          data[:vgrd])
        data[:wind_speed] = BuildSpotForecast.wind_speed(data[:ugrd],
          data[:vgrd])
      end
      if data[:precip_rate]
        data[:precip_rate] = BuildSpotForecast.hourly_prate(data[:precip_rate])
      end
      data
    end

  end

end
