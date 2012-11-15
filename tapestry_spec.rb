require 'rspec'
require './tapestry'

describe Kamishibai do
  it "should merge attributes that included newlines" do
    ksb = Kamishibai.new("./example_gamefile.txt")
    ksb.slideset.length.should == 4
  end
end
