
  Gem::Specification::new do |spec|
    spec.name = "tagz"
    spec.version = "5.1.0"
    spec.platform = Gem::Platform::RUBY
    spec.summary = "tagz"

    spec.files = ["gen_readme.rb", "install.rb", "lib", "lib/tagz.rb", "README", "README.tmpl", "samples", "samples/a.rb", "samples/b.rb", "samples/c.rb", "samples/d.rb", "samples/e.rb", "samples/f.rb", "samples/g.rb", "tagz-5.1.0.gem", "tagz.gemspec", "test", "test/tagz.rb"]
    spec.executables = []
    
    spec.require_path = "lib"

    spec.has_rdoc = true
    spec.test_files = "test/tagz.rb"
    #spec.add_dependency 'lib', '>= version'
    #spec.add_dependency 'fattr'

    spec.extensions.push(*[])

    spec.rubyforge_project = 'codeforpeople'
    spec.author = "Ara T. Howard"
    spec.email = "ara.t.howard@gmail.com"
    spec.homepage = "http://github.com/ahoward/tagz/tree/master"
  end

