require "AdobeColorBook/version"
require 'logger'

@logger = Logger.new(STDOUT)
@logger.level = Logger::DEBUG

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
  meta_blacklist = ['version','identifier']

    AdobeColorBook.constants.select { |cn| cn.to_s.include? 'IDENTIFIER' }.each do |c|
      c = c.to_s.split('_')[1]
      define_method "is_#{c.downcase}?" do
        @colorbook_options[:color_space_value] == c
      end
    end

    def setup_colorbook(colorbook_file, mode)
      @colorbook_file = File.new colorbook_file, mode
      @colorbook_options[:colors] ||= []
      @colorbook_file.read if mode == 'r'
    end
  
    def initialize(colorbook_file, colorbook_options = {})
      @colorbook_options = colorbook_options
      if File.file? colorbook_file
        setup_colorbook( colorbook_file, 'r' )
      else
        setup_colorbook( colorbook_file, 'w' )
      end




        puts self
    end

    def wrap_option(option_hash ,mthd)
      self.class.send(:define_method, mthd) do
        option_hash[mthd]
      end
      self.class.send(:define_method, "#{mthd}=") do |input|
        option_hash[mthd] = input
      end
    end


    def read
       File.open(@colorbook_file, 'rb:UTF-16LE' ) { |cbf| @colorbook_file = cbf
       read_header
       read_colors
       }

      # generating attributes for syntactic sugar colorbook.colorbook_options[:attr] -> colorbook.attr getter/setter
      # unless attr is in the blacklist
       @colorbook_options.each do |k,v|
          wrap_option(@colorbook_options, k) unless meta_blacklist.include? k
       end

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
      logger.debug(@colorbook_options)
    end

    def get_colors
      color_hash = {}
      @colorbook_options[:color_space_rname].chars.map { |c| color_hash["#{c}".to_sym]  }
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

        puts "Length: #{bytes_len}"

        3.times do
          color[:color_values] << @colorbook_file.read(1).unpack('C')
        end




        @logger.debug(color)


        @colorbook_options[:colors] << color
      end
    end
  end
end # end Module


AdobeColorBook::ColorBook.new "../test/spec/testfiles/HKS E.acb"