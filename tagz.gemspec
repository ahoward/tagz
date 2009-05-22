#! /usr/bin/env gem build

require 'rubygems'

Gem::Specification::new do |spec|
  #$VERBOSE = nil

  shiteless = lambda do |list|
    list.delete_if do |file|
      file =~ %r/\.svn/ or
      file =~ %r/\.tmp/
    end
  end

  lib = 'tagz'
  version = '5.1.0'

  spec.name = lib 
  spec.version = version 
  spec.platform = Gem::Platform::RUBY
  spec.summary = lib 

  spec.files = shiteless[Dir::glob("**/**")]
  spec.executables = shiteless[Dir::glob("bin/*")].map{|exe| File::basename exe}
  
  spec.require_path = "lib" 

  spec.has_rdoc = true #File::exist? "doc" 
  spec.test_suite_file = "test/#{ lib }.rb" if File::file?("test/#{ lib }.rb")
  #spec.add_dependency 'lib', '>= version'
  #spec.add_dependency 'fattr'

  spec.extensions << "extconf.rb" if File::exists? "extconf.rb"

  spec.rubyforge_project = 'codeforpeople'
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://codeforpeople.com/lib/ruby/#{ lib }/"
end


#BEGIN{ 
  #Dir.chdir(File.dirname(__FILE__))
  #$lib = 'tagz'
  #Kernel.load "./lib/#{ $lib }.rb"
  #$version = Tagz.version
#}
