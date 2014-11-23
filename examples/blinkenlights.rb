#!/usr/bin/env ruby

$: << 'lib'
require 'socket_switcher'

specifier = ARGV.shift or fail "need port specifier"
port = SocketSwitcher::Port.new(specifier, timeout: 2000, debug: true)
max = (ENV['MAX_DEVICE'] || 3).to_i
(0..max).map do |i|
  Thread.new do
    loop do
      begin
        d = port.device(i)
        rand < 0.5 ? d.on : d.off
        sleep rand
      rescue SocketSwitcher::CommunicationError => e
        warn "Caught #{e.class}: #{e} => exiting!"
        exit
      rescue SocketSwitcher::LigthSwitchError => e
        warn "Caught #{e.class}: #{e}"
        sleep rand
      end
    end
  end
end.each(&:join)
