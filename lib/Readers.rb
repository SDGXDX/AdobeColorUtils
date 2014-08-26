module AdobeColorUtils
  module Readers

    def read_string(size = BIT32)
      # Strings are variable, get the length, then the actual string. UTF-16, Not null-terminated
      while len = @colorbook_file.read(size)
        len = len.unpack('N').shift * 2 # *2 because length is 16-bit wide,
        return record = @colorbook_file.gets(len).encode('UTF-8')
      end
    end

    def read_int(size = BIT16)
      while len = @colorbook_file.read(size)
        return len.unpack('n').shift
      end
    end
  end
end