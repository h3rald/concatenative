#!/usr/bin/env ruby

require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"


Rake::TestTask.new do |test|
  test.libs       << "spec"
  test.test_files =  [ "spec/concatenative_spec.rb" ]
  test.verbose    =  true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README.rdoc",
                           "CHANGELOG.rdoc",
                           "LICENSE", "lib/" )
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "Concatenative Documentation"
end

spec = Gem::Specification.new do |s|
  s.name = %q{concatenative}
  s.version = "0.1.0"
  s.date = %q{2009-03-29}
  s.summary = %q{A Ruby DSL for concatenative programming.}
  s.email = %q{h3rald@h3rald.com}
  s.homepage = %q{http://rubyforge.org/projects/concatenative}
  s.rubyforge_project = %q{concatenative}
  s.description = %q{Concatenative can be used to program in Ruby using a concatenative syntax through ordinary arrays. Because of its high-level implementation, it is not nearly as fast as standard Ruby code. }
  s.has_rdoc = true
  s.authors = ["Fabio Cevasco"]
  s.files = FileList["{lib}/**/*"].to_a+FileList["{examples}/*"].to_a+FileList["{spec}/*"].to_a+["README.rdoc", "LICENSE", "CHANGELOG.rdoc"]
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "CHANGELOG.rdoc"]
	s.test_file  = 'spec/concatenative_spec.rb'  
end

Rake::GemPackageTask.new(spec) do |pkg|
	pkg.gem_spec = spec
  pkg.need_tar = true
	pkg.need_zip = true
end

