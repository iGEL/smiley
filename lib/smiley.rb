require 'yaml'

class Smiley
  def self.all_class
    defined?(@@all_class) ? @@all_class : 'smiley'
  end

  def self.all_class=(klass)
    @@all_class = klass
  end

  def self.each_class_prefix
    defined?(@@each_class_prefix) ? @@each_class_prefix : 'smiley'
  end

  def self.each_class_prefix=(klass)
    @@each_class_prefix = klass
  end

  def self.smiley_file=(file)
    @@smiley_file = file
  end

  def self.smiley_file
    if defined?(@@smiley_file)
      return @@smiley_file
    elsif defined?(Rails) && Rails.respond_to?(:root)
      return File.join(Rails.root, 'config', 'smileys.yml')
    end
  end

  def parse(text)
    load_smileys

    text = h(text).gsub(@@regex) do # to_str converts a ActiveSupport::SafeBuffer to a string
      %(#{$1}<em class="#{self.class.all_class} #{self.class.each_class_prefix}-#{@@smileys[$2].downcase}"></em>#{$3})
    end

    text.respond_to?(:html_safe) ? text.html_safe : text
  end

  private
  def h(str)
    if defined?(ERB::Utils) && ERB::Utils.respond_to?(:html_escape)
      ERB::Utils.html_escape(str).to_str
    else
      str.to_str
    end
  end

  def load_smileys
    unless defined?(@@smileys) && defined?(@@regex)
      @@smileys = {}
      @@regex = []
      YAML.load(File.read(Smiley.smiley_file)).each do |smiley, options|
        options['tokens'].split(/\s+/).each do |token|
          @@smileys[token] = smiley
          @@regex << Regexp.escape(token)
        end
      end
      before_and_after = "[.,;:!\\?\\(\\[\\{\\)\\]\\}\\-]|\\s"
      @@regex = Regexp.compile("(^|#{before_and_after})(" + @@regex.join("|") + ")($|#{before_and_after})", Regexp::MULTILINE)
    end
  end
end
