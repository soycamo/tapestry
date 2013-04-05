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
  SlipnSlide = Struct.new(:title, :raw_attributes, :attributes) do
    def to_twee
      twee = ":: #{title}\n"
      twee << attributes['description'] + "\n\n\n"
      twee
    end
  end

  def initialize(gamefile_path)
    gamefile = File.open(gamefile_path, 'r')
    raise "Can't load gamefile" unless gamefile
    @slideset = []
    current_slide = nil
    gamefile.each do |line|
      line = convert_to_utf8 line.strip 
      #line.strip!

      if line =~ %r{^\[(.+)\]}
        @slideset << current_slide unless current_slide.nil? 
        current_slide = SlipnSlide.new(line.gsub(/\[|\]/, ''), '', [])
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
          line = line.rjust(line.length + 1)
        # TODO: also handle comments
        elsif line =~ /[^\s]/
          # current_slide.attribues[last_attr] += line
        end
        current_slide.raw_attributes += line if current_slide
      end

    end
    # welp I forgot to "clear the cache" so to speak
    @slideset << current_slide
    
    # dang I wanna use @slideset.collect!(&:parse_attributes) 'cause I <3 that syntax
    #@slideset.collect! { |slide| Kamishibai.parse_attributes!(slide) }
  end

  def self.parse_attributes!(slide)
    attrs = slide.raw_attributes
    # TODO: need to qualify this gsub otherwise will break on email addresses.
    attrs = attrs.gsub('@', '||@').split('||')
    attrs.delete_if{|attr| attr.empty? }
    slide.attributes = Kamishibai.to_hash attrs
    slide
  end

  def self.to_hash ary
    hash = {}
    ary.collect do |str| 
      key, value = str.split(' = ')
      hash[key.tr('@', '').strip.downcase] = value
    end
    hash
  end

  def export
    puts @slideset.inspect
    #@slideset.each { |slide| puts slide.to_twee }
  end
end

