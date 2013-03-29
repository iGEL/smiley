require 'spec_helper'
require 'smiley'

describe Smiley do
  subject(:smiley) { described_class.new }


  after do
    described_class.class_eval do
      remove_class_variable :@@all_class if class_variable_defined?(:@@all_class)
      remove_class_variable :@@each_class_prefix if class_variable_defined?(:@@each_class_prefix)
      remove_class_variable :@@css_class_style if class_variable_defined?(:@@css_class_style)
      remove_class_variable :@@smiley_file if class_variable_defined?(:@@smiley_file)
    end
  end

  describe '.all_class' do
    before do
      described_class.smiley_file = File.join(File.dirname(__FILE__), "smileys.yml")
    end

    it 'defaults to smiley' do
      expect(described_class.all_class).to eq('smiley')
    end

    it 'returns the configured value' do
      described_class.all_class = 'funnyIcon'

      expect(described_class.all_class).to eq('funnyIcon')
    end
  end

  describe '.each_class_prefix' do
    it 'defaults to smiley' do
      expect(described_class.each_class_prefix).to eq('smiley')
    end

    it 'returns the configured value' do
      described_class.each_class_prefix = 'funnyIcon'

      expect(described_class.each_class_prefix).to eq('funnyIcon')
    end
  end

  describe '.smiley_file' do
    it 'returns the configured value' do
      described_class.smiley_file = '/etc/smileys.yml'

      expect(described_class.smiley_file).to eq('/etc/smileys.yml')
    end

    it 'returns nil, if not configured' do
      expect(described_class.smiley_file).to be_nil
    end

    it 'return \#{Rails.root}/config/smileys.yml, if Rails.root is defined"' do
      rails = double('Rails')
      stub_const('Rails', rails)
      rails.stub(:root) { '/home/igel/dev/example.com/' }

      expect(described_class.smiley_file).to eq('/home/igel/dev/example.com/config/smileys.yml')
    end
  end

  describe '.css_class_style' do
    it 'defaults to dashed' do
      expect(described_class.css_class_style).to eq(:dashed)
    end

    it 'returns :snake_case if configured' do
      described_class.css_class_style = :snake_case

      expect(described_class.css_class_style).to eq(:snake_case)
    end

    it 'returns :camel_case if configured' do
      described_class.css_class_style = :camel_case

      expect(described_class.css_class_style).to eq(:camel_case)
    end

    it 'raises an error if an invalid value is given' do
      expect { described_class.css_class_style = :strike_through }.to raise_error
    end
  end

  describe '#parse' do
    before do
      described_class.smiley_file = File.join(File.dirname(__FILE__), 'smileys.yml')
    end

    it 'parses a smiley' do
      expect(smiley.parse('That is so funny! :-) Will tell my grandma about that!')).to eq('That is so funny! <em class="smiley smiley-smile"></em> Will tell my grandma about that!')
    end

    it 'works with alternative forms' do
      expect(smiley.parse("That's so funny! :P Will tell my grandma about that :rolleyes: ")).to eq(%(That's so funny! <em class="smiley smiley-razz"></em> Will tell my grandma about that <em class="smiley smiley-rolleyes"></em> ))
    end

    it 'parses smileys at the beginning and end of a string' do
      expect(smiley.parse(':D So funny! ;-)')).to eq(%(<em class="smiley smiley-grin"></em> So funny! <em class="smiley smiley-wink"></em>))
    end

    it 'parses smileys at the beginning and end of a line' do
      expect(smiley.parse("\n:D So funny! ;-)\n")).to eq(%(\n<em class="smiley smiley-grin"></em> So funny! <em class="smiley smiley-wink"></em>\n))
    end

    it 'parses smileys after and before a comma, a dot, a question or exclamation mark, a semicolon, a colon, or a dash' do
      expect(smiley.parse("before: ,;-) .:-) ?:-) !;-) ;:D ::rolleyes: -:P\nafter: ;-), :-). :-)? ;-)! :D; :rolleyes:: :P-")).to eq(%(before: ,<em class="smiley smiley-wink"></em> .<em class="smiley smiley-smile"></em> ?<em class="smiley smiley-smile"></em> !<em class="smiley smiley-wink"></em> ;<em class="smiley smiley-grin"></em> :<em class="smiley smiley-rolleyes"></em> -<em class="smiley smiley-razz"></em>\nafter: <em class="smiley smiley-wink"></em>, <em class="smiley smiley-smile"></em>. <em class="smiley smiley-smile"></em>? <em class="smiley smiley-wink"></em>! <em class="smiley smiley-grin"></em>; <em class="smiley smiley-rolleyes"></em>: <em class="smiley smiley-razz"></em>-))
    end

    it 'parses smileys after and before round, box or curly brackets' do
      expect(smiley.parse(' (:-)) [:-)] {:-)} ')).to eq(' (<em class="smiley smiley-smile"></em>) [<em class="smiley smiley-smile"></em>] {<em class="smiley smiley-smile"></em>} ')
    end

    it "doesn't parse smileys directly before or after a word" do
      expect(smiley.parse(' :-)word:-) ')).to eq(' :-)word:-) ')
    end

    it 'uses the configured all_class and each_class_prefix' do
      described_class.all_class = 'funny-icon'
      described_class.each_class_prefix = 'smiley-image'

      expect(smiley.parse(':-)')).to eq('<em class="funny-icon smiley-image-smile"></em>')
    end

    it 'uses snake_case for the CSS class if configured' do
      described_class.css_class_style = :snake_case
      described_class.all_class = 'funny_icon'
      described_class.each_class_prefix = 'smiley_image'

      expect(smiley.parse(':-)')).to eq('<em class="funny_icon smiley_image_smile"></em>')
    end

    it 'uses CamelCase for the CSS class if configured' do
      described_class.css_class_style = :camel_case
      described_class.all_class = 'funnyIcon'
      described_class.each_class_prefix = 'smileyImage'

      expect(smiley.parse(':-)')).to eq('<em class="funnyIcon smileyImageSmile"></em>')
    end

    it 'uses ERB::Utils.html_escape if available' do
      erb_utils = double('ERB::Utils')
      stub_const('ERB::Utils', erb_utils)

      erb_utils.should_receive(:html_escape).with('<script>alert("Hacked!")</script>').and_return('&lt;script&gt;alert(&quot;Hacked!&quot;)&lt;/script&gt;')
      
      smiley.parse('<script>alert("Hacked!")</script>')
    end

    it 'marks the String as HTML safe, if that method is available' do
      String.any_instance.should_receive(:html_safe)

      smiley.parse(':-)')
    end
  end
end
