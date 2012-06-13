require 'spec_helper'
require 'smiley'

describe Smiley do
  describe '.smiley_file' do
    before do
      Smiley.class_eval do
        remove_class_variable :@@smiley_file if class_variable_defined?(:@@smiley_file)
      end
    end

    after do
      Object.send(:remove_const, :Rails) if defined?(Rails)
    end

    it "should return the value configured" do
      Smiley.smiley_file = "/etc/smileys.yml"

      Smiley.smiley_file.should == "/etc/smileys.yml"
    end

    it "should return nil, if not configured" do
      Smiley.smiley_file.should be_nil
    end

    it "should return \#{Rails.root}/config/smileys.yml, if Rails.root is defined" do
      Rails = double("Rails")
      Rails.stub(:root) { "/home/igel/dev/example.com/" }

      Smiley.smiley_file.should == "/home/igel/dev/example.com/config/smileys.yml"
    end
  end

  describe '#parse' do
    before do
      Smiley.smiley_file = File.join(File.dirname(__FILE__), "smileys.yml")
    end

    it "should parse a smiley" do
      Smiley.new.parse('That is so funny! :-) Will tell my grandma about that!').should == 'That is so funny! <em class="smiley smiley-smile"></em> Will tell my grandma about that!'
    end

    it "should work with alternative forms" do
      Smiley.new.parse("That's so funny! :P Will tell my grandma about that :rolleyes: ").should == %(That's so funny! <em class="smiley smiley-razz"></em> Will tell my grandma about that <em class="smiley smiley-rolleyes"></em> )
    end

    it "should parse smileys at the beginning and end of a string" do
      Smiley.new.parse(":D So funny! ;-)").should == %(<em class="smiley smiley-grin"></em> So funny! <em class="smiley smiley-wink"></em>)
    end

    it "should parse smileys at the beginning and end of a line" do
      Smiley.new.parse("\n:D So funny! ;-)\n").should == %(\n<em class="smiley smiley-grin"></em> So funny! <em class="smiley smiley-wink"></em>\n)
    end

    it "should parse smileys after and before a comma, a dot, a question or exclamation mark, a semicolon, a colon, or a dash" do
      Smiley.new.parse("before: ,;-) .:-) ?:-) !;-) ;:D ::rolleyes: -:P\nafter: ;-), :-). :-)? ;-)! :D; :rolleyes:: :P-").should == %(before: ,<em class="smiley smiley-wink"></em> .<em class="smiley smiley-smile"></em> ?<em class="smiley smiley-smile"></em> !<em class="smiley smiley-wink"></em> ;<em class="smiley smiley-grin"></em> :<em class="smiley smiley-rolleyes"></em> -<em class="smiley smiley-razz"></em>\nafter: <em class="smiley smiley-wink"></em>, <em class="smiley smiley-smile"></em>. <em class="smiley smiley-smile"></em>? <em class="smiley smiley-wink"></em>! <em class="smiley smiley-grin"></em>; <em class="smiley smiley-rolleyes"></em>: <em class="smiley smiley-razz"></em>-)
    end

    it "should parse smileys after and before round, box or curly brackets" do
      Smiley.new.parse(%! (:-)) [:-)] {:-)} !).should == %! (<em class="smiley smiley-smile"></em>) [<em class="smiley smiley-smile"></em>] {<em class="smiley smiley-smile"></em>} !
    end

    it "should not parse smileys directly before or after a word" do
      Smiley.new.parse(" :-)word:-) ").should == " :-)word:-) "
    end
  end
end
