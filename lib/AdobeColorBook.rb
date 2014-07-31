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
  INT16 = 2
# Color byte info
  IDENTIFIER_RGB = 0
  IDENTIFER_CMYK = 2
  IDENTIFIER_LAB = 7
  BYTES_CMYK = 4
  BYTES_RGB, BYTES_LAB = 3

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def read_string (colorbook = nil)
      # is this an instance?
      colorbook = (instance_variable_get("@colorbook_file").nil?) ? colorbook : @colorbook_file
      # Strings are variable, get the length, then the actual string. UTF-16, Not null-terminated
      while len = colorbook.read(STRING32)
        len = len.unpack('N').shift * 2  # *2 because length is 16-bit wide,
        puts len
        return record = colorbook.read(len)
      end
    end

    def read_int (colorbook = nil)
      # is this an instance?
      colorbook = (instance_variable_get("@colorbook_file").nil?) ? colorbook : @colorbook_file
      while len = colorbook.read(INT16)
        return len.unpack('n').shift
      end
    end
  end

  class ColorBook
    include(AdobeColorBook::ClassMethods)
  # Name of color is found by combining prefix, name and suffix: (PANTONE)( 763)(U)
  attr_accessor :version, :title, :identifier, :prefix, :suffix, :description,
                :color_count,  # number of color records in the book, MUST match the actual color count.
                :page_size, :page_selector_offset, # Photoshop UI information - size is number of colors per page, offset is WHICH color to show on page down
                :color_space,
                :colorbook_file, # store the file object to read and write
                :colors

    def initialize(colorbook_file = nil)
      #TODO: Refactor this to allow for nil entry to create a new book
      @colors = []
      unless colorbook_file.nil?
      @colorbook_file = colorbook_file
        File.open(@colorbook_file, 'rb' ) { |cbf| @colorbook_file = cbf
          read_header
          read_colors
        }
      end
    end

    def to_s
      instance_variables.each { |v| puts "#{v}: #{instance_variable_get(v)}"  }
    end

  private



    def read_header
      sig = @colorbook_file.read(SIGNATURE_LENGTH)
      @version, @identifier  = @colorbook_file.read(HEADER_LENGTH).unpack(HEADER_BLUEPRINT)
      puts "#{sig}, #{@version}, #{@identifier}"
      fail("This is not a valid colorbook file") unless sig == SIGNATURE
      @title = read_string
      @prefix = read_string
      @suffix = read_string
      @description = read_string
      @color_count = read_int
      @page_size = read_int
      @page_selector_offset = read_int
      @color_space = read_int
      @test = read_int
      puts self

    end

    def find_color_space
      AdobeColorBook.constants.select { |c| AdobeColorBook.const_get(c) == @color_space }.shift.to_s.split('_')[1]
    end

    def read_colors
      bytes_len = AdobeColorBook.const_get("BYTES_#{find_color_space}")
      #  TODO: Setup BookColor Class
      #  reading record: String for name, 6 bytes for short name, 3-4 bytes for color itself
    end
  end

  class ColorBookColor
    attr_accessor :name, :shortname, :color_values
    def initialize(color_opts = nil)
      @name = color_opts[:name]
      @shortname = color_opts[:shortname]
      @color_values = color_opts[:color_values]
    end

    private

    def read(file_ref)
      fail("File is not valid") unless File.file? file_ref
      @name = read_string file_ref
      @shortname = file_ref.read(6).unpack("cccccc")

    end
  end

end # end Module

def testit
AdobeColorBook::ColorBook.new "C:\\Users\\Owner\\Documents\\Contract\\Fischler\\acb2xml20\\PANTONE solid uncoated.acb"
end

testit