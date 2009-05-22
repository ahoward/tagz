Gem::Specification::new do |spec|
  lib = 'tagz'
  version = '5.1.0'

  spec.name = lib 
  spec.version = version 
  spec.platform = Gem::Platform::RUBY
  spec.summary = lib 

  spec.files = Dir::glob("**/**").delete_if{|f| f =~ %r/\.(svn|tmp)/}
  #spec.executables = Dir::glob("bin/*").delete_if{|f| f =~ %r/\.(svn|tmp)/}.map{|exe| File.basename(exe)}

  spec.require_path = "lib" 

  #spec.has_rdoc = true
  spec.test_files = "test/#{ lib }.rb"

  spec.rubyforge_project = 'codeforpeople'
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://codeforpeople.com/lib/ruby/#{ lib }/"
end
