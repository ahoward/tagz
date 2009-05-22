Gem::Specification::new do |spec|
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

  spec.has_rdoc = true
  spec.test_suite_file = "test/#{ lib }.rb" # if File::file?("test/#{ lib }.rb")

  # spec.extensions << "extconf.rb" if File::exists? "extconf.rb"

  spec.rubyforge_project = 'codeforpeople'
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://codeforpeople.com/lib/ruby/#{ lib }/"
end
