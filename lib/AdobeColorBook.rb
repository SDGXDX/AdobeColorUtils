require "AdobeColorBook/version"



module AdobeColorBook
  SIGNATURE = '8BCB'
  SIGNATURE_LENGTH = 4
  IDENTIFIER_RGB = 0
  IDENTIFER_CMYK = 2
  IDENTIFIER_LAB = 7
  CHAR_TRADEMARK = '^C'
  CHAR_REGISTERED = '^R'
  HEADER_BLUEPRINT = "nn"
  HEADER_LENGTH = 4
  STRING_LENGTH = 4

  class ColorBook
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

    def read_string
      # Strings are variable, get the length, then the actual string. UTF-16, Not null-terminated
      while len = @colorbook_file.read(STRING_LENGTH)
        len = len.unpack('N').shift * 2  # *2 because length is 16-bit wide,
        puts len
        return record = @colorbook_file.read(len)
      end
    end

    def read_int
      @colorbook_file.read(2).unpack('n').shift
    end

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

    def read_colors
      #  TODO: Setup BookColor Class
      #  reading record: String for name, 6 bytes for short name, 3-4 bytes for color itself
    end
  end
end # end Module

def testit
AdobeColorBook::ColorBook.new "C:\\Users\\Owner\\Documents\\Contract\\Fischler\\acb2xml20\\PANTONE solid uncoated.acb"
end

testit