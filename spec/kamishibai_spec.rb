# -*- coding: UTF-8 -*-
require 'rspec'
require './lib/kamishibai'
require 'pp'

describe Kamishibai do

  before do
    @ksb = Kamishibai.new("./example_gamefile.txt")
  end

  it "in a typical situation, should create correct number of slides" do
    @ksb.slideset.length.should == 2
  end

  it "should clean attributes" do
    example_slide_1 = @ksb.slideset.first
    clean_attributes_1 = 
      {"image" => "Conclusion.bmp",
       "music" => "shota(Rally the troops).mid",
       "description" => "Conclusion. Here you just basically touch things up and prepare the story for its final form to be published (read by others), so this is what you need to remember...",
       "option3" => "--->",
       "link3" => "A19",
       "option4" => "<---",
       "link4" => "A17"}

    example_slide_2 = @ksb.slideset.last
    clean_attributes_2 = 
        {"name"      => "Pastel Defender Heliotrope",
        "date"      => "May 24, 1998",
        "version"   => "First Publication",
        "author"    => "Jennifer Diane Reitz",
        "artist"    => "Jennifer Diane Reitz\nCharacters © 1998 Jennifer Diane Reitz",
        "company"   => "Accursed Toys, Inc.",
        "copyright" => "Copyright © 1998 by Accursed Toys, Inc.\nAll Rights Reserved.",
        "contact"   => "lupa@otakuworld.com"}

    example_slide_1.attributes.should == clean_attributes_1
    example_slide_2.attributes.should == clean_attributes_2
  end

  it "should return the correct number of attributes" do
    slide = @ksb.slideset.first
    slide.attributes.length.should == 7
  end

  it "should format a slide in Twee format" do
    twee_output = <<-TW
:: A18
Conclusion. Here you just basically touch things up and prepare the story for its final form to be published (read by others), so this is what you need to remember...


TW
    slide = @ksb.slideset.first
    slide.to_twee.should == twee_output 
  end
end
