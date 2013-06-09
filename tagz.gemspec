## tagz.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "tagz"
  spec.version = "9.8.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "tagz"
  spec.description = "\n        tagz.rb is generates html, xml, or any sgml variant like a small ninja\n        running across the backs of a herd of giraffes swatting of heads like\n        a mark-up weedwacker.  weighing in at less than 300 lines of code\n        tagz.rb adds an html/xml/sgml syntax to ruby that is both unobtrusive,\n        safe, and available globally to objects without the need for any\n        builder or superfluous objects.  tagz.rb is designed for applications\n        that generate html to be able to do so easily in any context without\n        heavyweight syntax or scoping issues, like a ninja sword through\n        butter.\n\n"

  spec.files = ["lib", "lib/tagz", "lib/tagz/rails.rb", "lib/tagz.rb", "Rakefile", "README", "readme.erb", "samples", "samples/a.rb", "samples/b.rb", "samples/c.rb", "samples/d.rb", "samples/e.rb", "samples/f.rb", "samples/g.rb", "tagz.gemspec", "test", "test/tagz_test.rb"]
  spec.executables = []
  
  spec.require_path = "lib"

  spec.has_rdoc = true
  spec.test_files = nil

# spec.add_dependency 'lib', '>= version'

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://github.com/ahoward/tagz"
end
