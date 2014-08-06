require "AdobeColorBook/version"



module AdobeColorBook
  SIGNATURE = '8BCB'
  SIGNATURE_LENGTH = 4
# header byte info
  CHAR_TRADEMARK = '^C'
  CHAR_REGISTERED = '^R'
  HEADER_BLUEPRINT = "nn"
  HEADER_LENGTH = 4
  STRING32 = 4
  INT32 = 4
  INT16 = 2
  INT8 = 1
# Color byte info
  IDENTIFIER_RGB = 0
  IDENTIFIER_CMYK = 2
  IDENTIFIER_LAB = 7
  BYTES_CMYK = 4
  BYTES_RGB, BYTES_LAB = 3

  def self.included(base)
    base.extend(Readers)
  end

  module Readers
    def read_string
      # Strings are variable, get the length, then the actual string. UTF-16, Not null-terminated
      while len = @colorbook_file.read(STRING32)
        len = len.unpack('N').shift * 2 # *2 because length is 16-bit wide,
        puts len
        return record = @colorbook_file.read(len).encode('UTF-8').unpack('U')
      end
    end

    def read_int(size = nil?)
      size ||= INT16
      while len = @colorbook_file.read(size)
        return len.unpack('n').shift
      end
    end
  end

  class ColorBook
  include(AdobeColorBook::Readers)
  # Name of color is found by combining prefix, name and suffix: (PANTONE)( 763)(U)
  attr_accessor :colorbook_file, :colorbook_options # store the file object to read and write

    AdobeColorBook.constants.select { |cn| cn.to_s.include? 'IDENTIFIER' }.each do |c|
      c = c.to_s.split('_')[1]
      define_method "is_#{c.downcase}?" do
        @colorbook_options[:color_space_value] == c
      end
    end

    def initialize(colorbook_file, colorbook_options = {})
      @colorbook_options = colorbook_options
      @colorbook_file = File.new colorbook_file if (colorbook_file.nil? || File.file?(colorbook_file))
      @colorbook_options[:colors] ||= []

        File.open(@colorbook_file, 'rb:UTF-16LE' ) { |cbf| @colorbook_file = cbf
          read_header
          read_colors
        }
        puts self
      end

    def to_s
      instance_variables.each { |v| puts "#{v}: #{instance_variable_get(v)}"  }
    end

  private



    def read_header
      sig = @colorbook_file.read(SIGNATURE_LENGTH)
      fail("This is not a valid colorbook file") unless sig == SIGNATURE

      @colorbook_options[:version] = read_int
      @colorbook_options[:identifier] = read_int
      puts "#{sig}, #{@colorbook_options[:version]}, #{@colorbook_options[:identifier]}"
      @colorbook_options[:title] = read_string
      @colorbook_options[:prefix] = read_string
      @colorbook_options[:suffix] = read_string
      @colorbook_options[:description] = read_string
      @colorbook_options[:color_count] = read_int
      @colorbook_options[:page_size] = read_int
      @colorbook_options[:page_selector_offset] = read_int
      @colorbook_options[:color_space_value] = read_int
      @colorbook_options[:color_space_name] = find_color_space_string
      puts @colorbook_options
    end

    def get_colors
      color_hash = {}
      @colorbook_options[:color_space_name].chars.map { |c| color_hash["#{c}".to_sym]  }
    end

    def find_color_space_string
     AdobeColorBook.constants.select { |c| AdobeColorBook.const_get(c) == @colorbook_options[:color_space_value] }.shift.to_s.split('_')[1]
    end



    def read_colors


      1.upto @colorbook_options[:color_count] do
        color = {
            name: read_string,
            shortname: @colorbook_file.read(6),
            color_values: []
        }
        puts @colorbook_options[:color_space_name]
        bytes_len = AdobeColorBook.const_get("BYTES_#{@colorbook_options[:color_space_name]}")
        3.times do
          color[:color_values] << @colorbook_file.read(1).unpack('C')
        end




        puts color


        @colorbook_options[:colors] << color
      end
    end
  end
end # end Module



