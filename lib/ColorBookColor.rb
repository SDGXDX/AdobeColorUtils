module AdobeColorUtils
  class ColorBookColor
    attr_accessor :name, :shortname,:color_values, :color_space

    def initialize(color_hash)
      def rgbmap() [:red,:green,:blue]; end
      def cmykmap() [:cyan,:magenta,:yellow,:black]; end
      def labmap() [:lightness,:a_chroma, :b_chroma]; end
      @name = color_hash[:name]
      @color_values = color_hash[:color_values]
      @color_space = color_hash[:color_space]
      @shortname = color_hash[:shortname]

      color_value_handling

      case
        when @color_space == 'LAB'
          setmap(labmap)
        when @color_space == 'RGB'
          setmap(rgbmap)
        when @color_space == 'CMYK'
      end

    end

    def setmap(maparray)
      maparray.each_with_index do |name,index|
        self.class.send(:define_method, name) { @color_values[index] }
        self.class.send(:define_method, "#{name}=") { |input| @color_values[index] = input }
      end
    end

    def color_value_handling
      0.upto @color_values.length-1 do |index|
        if @color_space == 'LAB'
          if index == 0
            @color_values[index] = ((@color_values[index] / 2.55)).round
          else
            @color_values[index] = @color_values[index] - 128
          end
        end
      end
    end

  end

end