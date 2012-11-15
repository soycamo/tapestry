class Kamishibai
  require 'iconv' unless String.method_defined?(:encode)
  attr_accessor :slideset

  # The Slip N Slide holds our wonky data.
  SlipnSlide = Struct.new(:title, :raw_attributes, :attributes) 

  def initialize(gamefile_path)
    #gamefile_path = File.expand_path "~/Projects/tapestry/test\ samples/KamishibaiMasterClass/gamefile.txt" #use ARGV here
    gamefile = File.open(gamefile_path, 'r')
    @slideset = []
    current_slide = nil
    gamefile.each do |line|
      # TODO change to auto detect encoding
      if String.method_defined?(:encode) 
        line.encode!('UTF-8', 'US-ASCII',{:invalid => :replace, :universal_newline => true})   
      else
        ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
        line = ic.iconv(line)
      end
      line.strip!
      #puts line
      if line =~ %r{^\[(.+)\]}
        @slideset << current_slide unless current_slide.nil? 
        # use line.tr
        current_slide = SlipnSlide.new(line[1..(line.length - 2)], '', [])
      else
        if line =~ %r{^\w}
          line = line.rjust(line.length + 1)
        end
        current_slide.raw_attributes += line if current_slide
      end

    end
    @slideset << current_slide
    
    # dang I wanna use @slideset.collect!(&:parse_attributes) 'cause I <3 that syntax
    @slideset.collect! { |slide| Kamishibai.parse_attributes!(slide) }
  end

  def self.parse_attributes!(slide)
    attrs = slide.raw_attributes
    attrs = attrs.gsub('@', '||@').split('||')
    attrs.delete_if{|attr| attr.empty? }
    slide.attributes = attrs
  end
end

#example = slideset.select { |slide| slide.title == "A4" }.first                            
#puts parse_attributes(example.raw_attributes) 
 

