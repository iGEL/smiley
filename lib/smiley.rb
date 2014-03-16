require 'yaml'

class Smiley
  VALID_CSS_CLASS_STYLES = [:dashed, :snake_case, :camel_case]

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

  def self.css_class_style
    defined?(@@css_class_style) ? @@css_class_style : :dashed
  end

  def self.css_class_style=(style)
    unless VALID_CSS_CLASS_STYLES.include?(style.to_sym)
      raise "Invalid css class style #{style}. You can choose between :dashed, :snake_case and :camel_case"
    end
    @@css_class_style = style.to_sym
  end

  def self.smiley_file
    if defined?(@@smiley_file)
      return @@smiley_file
    elsif defined?(Rails) && Rails.respond_to?(:root)
      return File.join(Rails.root, 'config', 'smileys.yml')
    end
  end

  def parse(text)
    text = h(text).gsub(self.class.regex) do
      %(<em class="#{css_class(self.class.smileys[$1])}"></em>)
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

  def css_class(smiley)
    out = "#{self.class.all_class} #{self.class.each_class_prefix}-#{smiley}"
    case self.class.css_class_style
    when :camel_case
      camelize(out)
    when :snake_case
      underscore(out)
    else
      out
    end
  end

  def camelize(str)
    str.gsub(/-([a-z])/) { $1.upcase }
  end

  def underscore(str)
    str.gsub('-', '_')
  end

  def self.smileys
    return @@smileys if  defined?(@@smileys)

    @@smileys = {}
    YAML.load(File.read(Smiley.smiley_file)).each do |smiley, options|
      options['tokens'].split(/\s+/).each do |token|
        @@smileys[token] = smiley
      end
    end
    @@smileys
  end

  def self.regex
    return @@regex if defined?(@@regex)

    before_and_after = "[.,;:!\\?\\(\\[\\{\\)\\]\\}\\-]|\\s"
    @@regex = Regexp.compile(
      "(?<=^|#{before_and_after})" +
      "(" + smileys.keys.map { |token| Regexp.escape(token) }.join("|") + ")" +
      "(?=$|#{before_and_after})",
      Regexp::MULTILINE
    )
  end
end
