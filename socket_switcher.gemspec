# -*- encoding: utf-8 -*-
# stub: socket_switcher 0.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "socket_switcher"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Florian Frank"]
  s.date = "2015-01-01"
  s.description = "Switches devices on and off. Yes, it does\u{2026}"
  s.email = "flori@ping.de"
  s.extra_rdoc_files = ["README.md", "lib/socket_switcher.rb", "lib/socket_switcher/device.rb", "lib/socket_switcher/errors.rb", "lib/socket_switcher/port.rb", "lib/socket_switcher/version.rb"]
  s.files = [".gitignore", ".rspec", ".utilsrc", "Gemfile", "README.md", "Rakefile", "VERSION", "arduino-receiver/receiver/receiver.ino", "arduino/lib/.holder", "arduino/lib/RCSwitch/RCSwitch.cpp", "arduino/lib/RCSwitch/RCSwitch.h", "arduino/lib/RCSwitch/examples/ReceiveDemo_Advanced/ReceiveDemo_Advanced.pde", "arduino/lib/RCSwitch/examples/ReceiveDemo_Advanced/helperfunctions.ino", "arduino/lib/RCSwitch/examples/ReceiveDemo_Advanced/output.ino", "arduino/lib/RCSwitch/examples/ReceiveDemo_Simple/ReceiveDemo_Simple.pde", "arduino/lib/RCSwitch/examples/SendDemo/SendDemo.pde", "arduino/lib/RCSwitch/examples/TypeA_WithDIPSwitches/TypeA_WithDIPSwitches.pde", "arduino/lib/RCSwitch/examples/TypeA_WithDIPSwitches_Lightweight/TypeA_WithDIPSwitches_Lightweight.ino", "arduino/lib/RCSwitch/examples/TypeB_WithRotaryOrSlidingSwitches/TypeB_WithRotaryOrSlidingSwitches.pde", "arduino/lib/RCSwitch/examples/TypeC_Intertechno/TypeC_Intertechno.pde", "arduino/lib/RCSwitch/examples/TypeD_REV/TypeD_REV.ino", "arduino/lib/RCSwitch/examples/Webserver/Webserver.pde", "arduino/lib/RCSwitch/keywords.txt", "arduino/src/switcher/switcher.ino.erb", "examples/blinkenlights.rb", "lib/socket_switcher.rb", "lib/socket_switcher/device.rb", "lib/socket_switcher/errors.rb", "lib/socket_switcher/port.rb", "lib/socket_switcher/version.rb", "socket_switcher.gemspec", "spec/socket_switcher/device_spec.rb", "spec/socket_switcher/port_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/flori/socket_switcher"
  s.licenses = ["GPL-2"]
  s.rdoc_options = ["--title", "SocketSwitcher - Switches devices on and off", "--main", "README.md"]
  s.rubygems_version = "2.2.2"
  s.summary = "Switches devices on and off"
  s.test_files = ["spec/socket_switcher/device_spec.rb", "spec/socket_switcher/port_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 1.1.2"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.9"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_runtime_dependency(%q<tins>, ["~> 1.0"])
      s.add_runtime_dependency(%q<serialport>, ["~> 1.3"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 1.1.2"])
      s.add_dependency(%q<simplecov>, ["~> 0.9"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<tins>, ["~> 1.0"])
      s.add_dependency(%q<serialport>, ["~> 1.3"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 1.1.2"])
    s.add_dependency(%q<simplecov>, ["~> 0.9"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<tins>, ["~> 1.0"])
    s.add_dependency(%q<serialport>, ["~> 1.3"])
  end
end
