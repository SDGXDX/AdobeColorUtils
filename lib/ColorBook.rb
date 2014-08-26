module AdobeColorUtils
  class ColorBook
    include(AdobeColorUtils::Readers)

    # Name of color is found by combining prefix, name and suffix: (PANTONE)(763)(U)
    attr_accessor :colorbook_file, :colorbook_options # store the file object to read and write


    def meta_blacklist
      ['version','identifier']
    end

    def wrap_option(option_hash, mthd)
      self.class.send(:define_method, mthd) do
        option_hash[mthd]
      end
      self.class.send(:define_method, "#{mthd}=") do |input|
        option_hash[mthd] = input
      end
    end

    AdobeColorUtils.constants.select { |cn| cn.to_s.include? 'IDENTIFIER' }.each do |c|
      c = c.to_s.split('_')[1]
      define_method "is_#{c.downcase}?" do
        @colorbook_options[:color_space_value] == c
      end
    end

    def read_colorbook
      open(@colorbook_file, mode: 'rb:UTF-16BE') do |cbf|
        @colorbook_file = cbf
        read_header
        read_colors
        @colorbook_options[:spot_or_process] =  @colorbook_file.gets(8)
      end

      # generating attributes for syntactic sugar colorbook.colorbook_options[:attr] -> colorbook.attr getter/setter
      # unless attr is in the blacklist
      @colorbook_options.each do |k,v|
        wrap_option(@colorbook_options, k) unless meta_blacklist.include? k
      end

    end


    def setup_colorbook(colorbook_file, mode)
      @colorbook_file = File.new colorbook_file
      @colorbook_options[:colors] ||= []
      if mode == "r"
        read_colorbook
      end
    end

    def initialize(colorbook_file, colorbook_options = {})
      @colorbook_options = colorbook_options
      (File.file? colorbook_file) ? setup_colorbook(colorbook_file, 'r') : setup_colorbook(colorbook_file, 'w')
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
    end

    def get_colors
      color_hash = {}
      @colorbook_options[:color_space_rname].chars.map { |c| color_hash["#{c}".to_sym]  }
    end

    def find_color_space_string
      AdobeColorUtils.constants.select { |c| AdobeColorUtils.const_get(c) == @colorbook_options[:color_space_value] }.shift.to_s.split('_')[1]
    end

    def read_colors
      1.upto @colorbook_options[:color_count] do
        color_hash = {
            name: read_string,
            shortname: @colorbook_file.read(6),
            color_values: [],
            color_space: @colorbook_options[:color_space_name]
        }

        bytes_len = AdobeColorUtils.const_get("BYTES_#{@colorbook_options[:color_space_name]}")

        1.upto(bytes_len) do
          color_hash[:color_values] << @colorbook_file.read(1).unpack('C').shift
        end
        color = AdobeColorUtils::ColorBookColor.new color_hash
        @colorbook_options[:colors] << color
      end
    end


  end
end