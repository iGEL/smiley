require 'yaml'

class Smiley
  def self.smiley_file=(file)
    @@smiley_file = file
  end

  def self.smiley_file
    return @@smiley_file if defined?(@@smiley_file)
    return File.join(Rails.root, "config", "smileys.yml") if defined?(Rails) && Rails.respond_to?(:root)
    nil
  end

  def parse(text)
    load_smileys

    text.to_str.gsub(@@regex) do # to_str converts a ActiveSupport::SafeBuffer to a string
      %(#{$1}<em class="smiley smiley-#{@@smileys[$2].downcase}"></em>#{$3})
    end
  end

  private
  def load_smileys
    unless defined?(@@smileys) && defined?(@@regex)
      @@smileys = {}
      @@regex = []
      YAML.load(File.read(Smiley.smiley_file)).each do |smiley, options|
        options["tokens"].split(/\s+/).each do |token|
          @@smileys[token] = smiley
          @@regex << Regexp.escape(token)
        end
      end
      before_and_after = "[.,;:!\\?\\(\\[\\{\\)\\]\\}\\-]|\\s"
      @@regex = Regexp.compile("(^|#{before_and_after})(" + @@regex.join("|") + ")($|#{before_and_after})", Regexp::MULTILINE)
    end
  end
end
