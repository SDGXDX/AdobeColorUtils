require_relative 'spec_helper'

describe 'Open and Read ACB Files' do

  it 'should Open and Read ACB Files' do
    Dir['testfiles/*.acb'].each do |f|
     @cb = AdobeColorUtils::ColorBook.new f
     puts @cb
      @cb.should be_instance_of AdobeColorUtils::ColorBook
    end
  end
end

describe 'Does file exist catch' do

  it 'should create a new file if passed file doesn\'t exist' do
    @testfile_string = 'mytestfile.acb'
       (File.delete @testfile_string) if (File.exists? @testfile_string)
        @cb = AdobeColorUtils::ColorBook.new @testfile_string
        (File.exists? @testfile_string) == true
    end
end

describe 'Color count is accurate' do

  it 'should match color count against actual number of colors'
  Dir['testfiles/*.acb'].each do |f|
    @cb = AdobeColorUtils::ColorBook.new f
      assert_equals(@cb.colors.length, @cb.color_count)
  end
end