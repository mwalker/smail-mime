Gem::Specification.new do |s|
  s.name          = "smail-mime"
  s.version       = "0.0.5"
  s.author        = "Matthew Walker"
  s.email         = "matthew@walker.wattle.id.au"
  s.homepage      = "http://github.com/mwalker/smail-mime"
  s.summary       = "A simple MIME email parser"
  s.files         = ["lib/smail/mime.rb", "lib/smail/mime/coding_extensions.rb", "lib/smail/mime/content_fields.rb", "lib/smail/mime/date.rb", "lib/smail/mime/header.rb", "lib/smail/mime/mime.rb", "lib/smail/mime/version.rb"]
  s.require_path  = "lib"
  s.has_rdoc      = false
  #s.add_dependency('smail', '>=0.0.4') 
  s.requirements  << 'smail gem >=0.0.4' # Not a dependency so it can be installed via github
  s.add_dependency('activesupport', '>=2.0.0') 
  s.add_development_dependency('rspec', '>=1.0.5') 
end
