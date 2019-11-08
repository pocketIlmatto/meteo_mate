module MeteoMate

  class Configuration
    attr_accessor :wgrib2_path, :records

    def initialize
      @wgrib2_path = "wgrib"
      @records = {
        :cloud_cover  => ":TCDC:entire atmosphere:",
        :cloud_base => ":HGT:cloud base:",
        :gust => ":GUST:surface:",
        :precip_rate => ":PRATE:surface:",
        :temp   => ":TMP:2 m above ground:",
        :ugrd  => ":UGRD:10 m above ground:",
        :vgrd  => ":VGRD:10 m above ground:"
      }
    end

    def self.configure(options)
      options.each do |option, value|
        self[option] = value
      end
    end
  end

end