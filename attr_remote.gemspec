Gem::Specification.new do |s|
  s.name     = "attr_remote"
  s.version  = "0.0.5"
  s.date     = "2008-01-06"
  s.summary  = "Painlessly integrate ActiveResource into ActiveRecord."
  s.email    = "smithk14@gmail.com"
  s.homepage = "http://github.com/codebrulee/attr_remote"
  s.description = "Painlessly integrate ActiveResource into ActiveRecord."
  s.has_rdoc = true
  s.authors  = ["Kevin Smith"]
  s.files    = [
  	"README.rdoc",
  	"attr_remote.gemspec",
    "LICENSE",
    "lib/attr_remote.rb"
  ]
  
  s.test_files = [
    "test/test_attr_remote.rb",
    "test/helper.rb",
    "test/factories.rb",
    "test/db/test.db",
    "test/models/bob.rb",
    "test/models/remote_bob.rb",
    "test/models/user.rb",
    "test/models/remote_user.rb",
  ]

  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["README.rdoc"]
end