require 'spec_helper'
require 'smiley'

describe Smiley do
  describe '.all_class' do
    before do
      Smiley.smiley_file = File.join(File.dirname(__FILE__), "smileys.yml")
    end

    after do
      Smiley.class_eval do
        remove_class_variable :@@all_class if class_variable_defined?(:@@all_class)
      end
    end

    it 'defaults to smiley' do
      expect(Smiley.all_class).to eq('smiley')
    end

    it 'returns the configured value' do
      Smiley.all_class = 'funnyIcon'

      expect(Smiley.all_class).to eq('funnyIcon')
    end
  end

  describe '.each_class_prefix' do
    after do
      Smiley.class_eval do
        remove_class_variable :@@each_class_prefix if class_variable_defined?(:@@each_class_prefix)
      end
    end

    it 'defaults to smiley' do
      expect(Smiley.each_class_prefix).to eq('smiley')
    end

    it 'returns the configured value' do
      Smiley.each_class_prefix = 'funnyIcon'

      expect(Smiley.each_class_prefix).to eq('funnyIcon')
    end
  end

  describe '.smiley_file' do
    before do
      Smiley.class_eval do
        remove_class_variable :@@smiley_file if class_variable_defined?(:@@smiley_file)
      end
    end

    after do
      Object.send(:remove_const, :Rails) if defined?(Rails)
    end

    it 'returns the configured value' do
      Smiley.smiley_file = '/etc/smileys.yml'

      expect(Smiley.smiley_file).to eq('/etc/smileys.yml')
    end

    it 'returns nil, if not configured' do
      expect(Smiley.smiley_file).to be_nil
    end

    it 'return \#{Rails.root}/config/smileys.yml, if Rails.root is defined"' do
      Rails = double('Rails')
      Rails.stub(:root) { '/home/igel/dev/example.com/' }

      expect(Smiley.smiley_file).to eq('/home/igel/dev/example.com/config/smileys.yml')
    end
  end

  describe '#parse' do
    before do
      Smiley.smiley_file = File.join(File.dirname(__FILE__), 'smileys.yml')
    end

    it 'parses a smiley' do
      expect(Smiley.new.parse('That is so funny! :-) Will tell my grandma about that!')).to eq('That is so funny! <em class="smiley smiley-smile"></em> Will tell my grandma about that!')
    end

    it 'works with alternative forms' do
      expect(Smiley.new.parse("That's so funny! :P Will tell my grandma about that :rolleyes: ")).to eq(%(That's so funny! <em class="smiley smiley-razz"></em> Will tell my grandma about that <em class="smiley smiley-rolleyes"></em> ))
    end

    it 'parses smileys at the beginning and end of a string' do
      expect(Smiley.new.parse(':D So funny! ;-)')).to eq(%(<em class="smiley smiley-grin"></em> So funny! <em class="smiley smiley-wink"></em>))
    end

    it 'parses smileys at the beginning and end of a line' do
      expect(Smiley.new.parse("\n:D So funny! ;-)\n")).to eq(%(\n<em class="smiley smiley-grin"></em> So funny! <em class="smiley smiley-wink"></em>\n))
    end

    it 'parses smileys after and before a comma, a dot, a question or exclamation mark, a semicolon, a colon, or a dash' do
      expect(Smiley.new.parse("before: ,;-) .:-) ?:-) !;-) ;:D ::rolleyes: -:P\nafter: ;-), :-). :-)? ;-)! :D; :rolleyes:: :P-")).to eq(%(before: ,<em class="smiley smiley-wink"></em> .<em class="smiley smiley-smile"></em> ?<em class="smiley smiley-smile"></em> !<em class="smiley smiley-wink"></em> ;<em class="smiley smiley-grin"></em> :<em class="smiley smiley-rolleyes"></em> -<em class="smiley smiley-razz"></em>\nafter: <em class="smiley smiley-wink"></em>, <em class="smiley smiley-smile"></em>. <em class="smiley smiley-smile"></em>? <em class="smiley smiley-wink"></em>! <em class="smiley smiley-grin"></em>; <em class="smiley smiley-rolleyes"></em>: <em class="smiley smiley-razz"></em>-))
    end

    it 'parses smileys after and before round, box or curly brackets' do
      expect(Smiley.new.parse(' (:-)) [:-)] {:-)} ')).to eq(' (<em class="smiley smiley-smile"></em>) [<em class="smiley smiley-smile"></em>] {<em class="smiley smiley-smile"></em>} ')
    end

    it "doesn't parse smileys directly before or after a word" do
      expect(Smiley.new.parse(' :-)word:-) ')).to eq(' :-)word:-) ')
    end
  end
end
