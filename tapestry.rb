require 'pp'

module KamishibaiUtils
  require 'iconv' unless String.method_defined?(:encode)

  def convert_to_utf8(str)
    # TODO change to auto detect encoding
    if String.method_defined?(:encode) 
      str.encode!('UTF-8', 'US-ASCII',{:invalid => :replace, :universal_newline => true})   
    else
      ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
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
      twee << attributes['description'] + "\n"
      twee
    end
  end

  def initialize(gamefile_path)
    #gamefile_path = File.expand_path "~/Projects/tapestry/test\ samples/KamishibaiMasterClass/gamefile.txt" #use ARGV here
    gamefile = File.open(gamefile_path, 'r')
    @slideset = []
    current_slide = nil
    gamefile.each do |line|
      line = convert_to_utf8 line 
      line.strip!

      if line =~ %r{^\[(.+)\]}
        @slideset << current_slide unless current_slide.nil? 
        # use line.tr
        current_slide = SlipnSlide.new(line.gsub(/\[|\]/, ''), '', [])
      else
        if line =~ %r{^\w}
          line = line.rjust(line.length + 1)
        end
        current_slide.raw_attributes += line if current_slide
      end

    end
    # welp I forgot to "clear the cache" so to speak
    @slideset << current_slide
    
    # dang I wanna use @slideset.collect!(&:parse_attributes) 'cause I <3 that syntax
    @slideset.collect! { |slide| Kamishibai.parse_attributes!(slide) }
  end

  def self.parse_attributes!(slide)
    attrs = slide.raw_attributes
    attrs = attrs.gsub('@', '||@').split('||')
    attrs.delete_if{|attr| attr.empty? }
    slide.attributes = Kamishibai.to_hash attrs
    slide
  end

  def self.to_hash ary
    hash = {}
    ary.collect do |str| 
      key, value = str.split(' = ')
      hash[key.tr('@', '')] = value
    end
    hash
  end
end

#example = slideset.select { |slide| slide.title == "A4" }.first                            
#puts parse_attributes(example.raw_attributes) 
 

