# 
# camo wrote this code
# it is MIT licensed
# it is not edible
# proceed with caution
#

module KamishibaiUtils
  require 'iconv' unless String.method_defined?(:encode)

  def convert_to_utf8(str)
    # TODO change to auto detect encoding
    if String.method_defined?(:encode) 
      str.encode!('UTF-8', 'Windows-1252', :invalid => :replace)   
    else
      ic = Iconv.new('Windows-1252', 'UTF-8//IGNORE')
      str = ic.iconv(str)
    end
  end
end

class Kamishibai
  include KamishibaiUtils

  attr_accessor :slideset

  # The Slip N Slide holds our wonky data.
  SlipnSlide = Struct.new(:title, :attributes) do
    def to_twee
      twee = ":: #{title}\n"
      twee << attributes['description'] + "\n\n\n"
      twee
    end
  end

  def initialize(gamefile_path)
    @slideset = []
    @gamefile = File.open(gamefile_path, 'r')
    raise "Can't load gamefile" unless @gamefile
    current_slide = nil
    last_attr = nil
    @gamefile.each do |line|
      line = convert_to_utf8 line.strip 
      #line.strip!

      if line =~ %r{^\[(.+)\]}
        @slideset << current_slide unless current_slide.nil? 
        current_slide = SlipnSlide.new(line.gsub(/\[|\]/, ''), [])
        current_slide.attributes = {}
      else
        if line =~ /^@/
          # @attr = "some = thing"
          # /(@\w+) = (.*)/
          # remote @
          # current_slide.attributes["attr"] = "some thing"
          _, key, value = line.split(/\A(@\w+)\s+=\s(.*)/)
          key = key.tr('@', '').strip.downcase
          current_slide.attributes[key] = value
          last_attr = key
        # TODO: also handle comments
        elsif line =~ /[^\s]/
          line = line.rjust(line.length + 1)
          current_slide.attributes[last_attr] += line
        end
      end

    end
    # welp I forgot to "clear the cache" so to speak
    @slideset << current_slide

  end

  def export
    puts @slideset.inspect
    #@slideset.each { |slide| puts slide.to_twee }
  end
end

