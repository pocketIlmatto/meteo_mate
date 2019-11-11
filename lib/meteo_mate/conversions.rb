module MeteoMate

  module Conversions

    def hourly_prate(prate)
      prate * 3600
    end

    def temp_k_to_c(temp)
      temp - 273.15
    end

    def wind_direction(ugrd, vgrd)
      (270 - Math.atan2(ugrd, vgrd) * 180 / Math::PI) % 360
    end

    def wind_speed(ugrd, vgrd)
      Math.sqrt(ugrd**2 + vgrd**2)
    end

  end
end