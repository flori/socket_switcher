# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'socket_switcher'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "http://github.com/flori/#{name}"
  summary     'Switches devices on and off'
  description "#{summary}. Yes, it does…"
  licenses    << 'GPL-2'
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.rvmrc', 'coverage',
    'tags', '.bundle', '.DS_Store', '.build'

  readme      'README.md'
  executables.merge Dir['bin/*'].map { |x| File.basename(x) }

  dependency             'tins',        '~>1.0'
  dependency             'serialport',  '~>1.3'
  dependency             'complex_config'
  development_dependency 'simplecov',   '~>0.9'
  development_dependency 'rspec',       '~>3.0'

  default_task_dependencies :spec
end


arduino_src = 'arduino/src/switcher/switcher.ino.erb'
arduino_dst = 'arduino/src/switcher/switcher.ino'
CLOBBER.include arduino_dst

template arduino_src  do
  require 'complex_config/rude'
  config = complex_config(ENV['CONFIG'] || 'default')
  device_on    config.devices.map(&:enable)
  device_off   config.devices.map(&:disable)
  device_max   config.devices.size - 1
  transmit_pin config.transmit_pin
end

desc 'Compile and upload arduino code'
task :arduino => arduino_dst do
  cd 'arduino' do
    if `which ino`.empty?
      fail 'install ino command line toolkit with "pip install ino" or "easy_install ino"'
    end
    sh 'ino clean'
    model = ENV['MODEL'] || 'uno'
    sh "ino build -m #{model}"
    sh "ino upload -m #{model}#{' -p ' + ENV['PORT'] if ENV.key?('PORT')}"
  end
end
