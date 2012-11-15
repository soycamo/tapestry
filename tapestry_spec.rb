require 'rspec'
require './tapestry'
require 'pp'

describe Kamishibai do

  before do
    @ksb = Kamishibai.new("./example_gamefile.txt")
  end

  it "in a typical situation, should create correct number of slides" do
    @ksb.slideset.length.should == 4
  end

  it "should merge attributes that included newlines" do
    pending
    slide = @ksb.slideset.first
    clean_attributes = 
      ["@image = Conclusion.bmp",
       "@music = shota(Rally the troops).mid",
       "@description = Conclusion. Here you just basically touch things up and prepare the story for its final form to be published (read by others), so this is what you need to remember...",
       "@option3 = --->",
       "@link3 = A19",
       "@option4 = <---",
       "@link4 = A17"]

    Kamishibai.parse_attributes!(slide).should == clean_attributes
  end

  it "should return the correct number of attributes" do
    slide = @ksb.slideset.first
    slide.attributes.length.should == 7
  end
end
