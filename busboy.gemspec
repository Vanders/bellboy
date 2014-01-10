# encoding: utf-8

Gem::Specification.new do |g|
  g.name                    = 'busboy'
  g.version                 = IO.read(File.join(File.dirname(__FILE__), "VERSION")) rescue "0.0.1"
  g.summary                 = "Manage data bags with Berkshelf"
  g.description             = "Version, install & upload data bag items that are stored alongside your Berkshelf Cookbooks"
  g.authors                 = ["Kristian Van Der Vliet"]
  g.email                   = 'kvandervliet@dyn.com'
  g.homepage                = ''
  g.license                 = 'Apache-2.0'

  g.files                   = `git ls-files`.split($\)
  g.executables             = g.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

  g.add_runtime_dependency 'thor',      '~> 0.18.0'
  g.add_runtime_dependency 'berkshelf', '~> 2.10.0'
end
