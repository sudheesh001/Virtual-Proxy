# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-proxyconf/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-proxyconf"
  spec.version       = VagrantPlugins::ProxyConf::VERSION
  spec.authors       = ["Sudheesh Singanamalla"]
  spec.email         = ["sudheesh1995@outlook.com"]
  spec.description   = "An enhancement of the original Vagrant plugin that configures the virtual machine to use proxy servers (SOCKS5/4/ADC)"
  spec.summary       = spec.description
  spec.homepage      = "http://github.com/sudheesh001/virtual-proxy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
