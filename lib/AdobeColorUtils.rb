require "AdobeColorBook/version"
require_relative "Readers"
require_relative "ColorBook"
require_relative "ColorBookColor"
require_relative "SwatchBook"

module AdobeColorUtils
  SIGNATURE = '8BCB'
  SIGNATURE_LENGTH = 4
# header byte info
  CHAR_TRADEMARK = '^C'
  CHAR_REGISTERED = '^R'

  BIT32 = 4
  BIT16 = 2
  BIT8 = 1

# Color byte info
  IDENTIFIER_RGB = 0
  IDENTIFIER_CMYK = 2
  IDENTIFIER_LAB = 7
  BYTES_CMYK = 4
  BYTES_RGB = 3
  BYTES_LAB = 3

  def self.included(base)
    base.extend(Readers)
  end

end # end Module


cb = AdobeColorUtils::ColorBook.new "../test/spec/testfiles/PANTONE solid coated.acb"
puts cb.prefix + cb.title + cb.suffix
puts cb.colors
puts cb.colors.length
puts cb.colors[0].lightness
cb.colors[0].lightness = 123
puts cb.colors[0].lightness
puts cb.spot_or_process