module SocketSwitcher
  class SocketSwitcherError < StandardError
    def self.for_device(device, message)
      new(message).tap do |error|
        error.device = device
      end
    end

    def self.wrap(device, exception)
      for_device(device, "wrapped #{exception.class}: #{exception}").tap do |e|
        e.set_backtrace exception.backtrace
      end
    end

    attr_accessor :device
  end

  class CommunicationError < SocketSwitcherError
  end

  class InvalidResponse < SocketSwitcherError
  end

  class TryAgainError < SocketSwitcherError
  end
end
