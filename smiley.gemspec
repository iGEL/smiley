Gem::Specification.new do |s|
  s.name = %q{smiley}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 1.9.3'
  s.authors = ["Johannes Barre"]
  s.date = Time.now.strftime("%Y-%m-%d")
  s.email = %q{igel@igels.net}
  s.extra_rdoc_files = [
  ]
  s.files = [
    "README.md",
    "MIT-LICENSE",
    "Rakefile",
    "Gemfile",
    "lib/smiley.rb",
    "spec/smiley_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{https://github.com/igel/smiley}
  s.require_paths = ["lib"]
  s.required_rubygems_version = ">= 1.3.6"
  s.summary = %q{A small lib to parse smileys. Use CSS to display them!}
  s.test_files = [
    "spec/smiley_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.add_development_dependency('rake', '~> 10.0')
  s.add_development_dependency('rspec', '~> 3.0')
end
