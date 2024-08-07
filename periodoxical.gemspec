
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "periodoxical/version"

Gem::Specification.new do |spec|
  spec.name          = "periodoxical"
  spec.version       = Periodoxical::VERSION
  spec.authors       = ["Steven Li"]
  spec.email         = ["stevenji@gmail.com"]

  spec.summary       = %q{Generating date/times based on rules.  Perfect for (but not limited to) calendar/scheduling applications.}
  spec.description   = %q{Generating date/times based on rules.  Perfect for (but not limited to) calendar/scheduling applications. Generate times based on rules like days of the week, timezones, time blocks, start dates, end dates, etc.}
  spec.homepage      = "https://github.com/StevenJL/periodoxical"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/StevenJL/periodoxical"
    spec.metadata["changelog_uri"] = "https://github.com/StevenJL/periodoxical"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'tzinfo', '~> 2.0', '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug", "~> 3.10"
  spec.add_development_dependency "pry-stack_explorer", "~> 0.6"

  spec.required_ruby_version = '>= 3.0.0'
end
