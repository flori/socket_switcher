require 'serialport'
require 'thread'

class SocketSwitcher::Port
  def initialize(specifier, debug: false, timeout: 2_000, attempts: 3)
    @serial_port = SerialPort.new(
      specifier,
      "baud"      => 9600,
      "data_bits" => 8,
      "stop_bits" => 1,
      "parity"    => 0
    )
    @debug    = debug
    @timeout  = timeout
    @attempts = attempts
    @devices  = {}
    @mutex    = Mutex.new
  rescue => e
    raise SocketSwitcher::CommunicationError.wrap(nil, e)
  end

  attr_accessor :debug

  attr_accessor :timeout

  def ready?
    request do |response|
      if response =~ /^RDY (\d+) (\d+)/
        # initalize all devices
        ($1.to_i..$2.to_i).each { |i| device(i) }
        return true
      else
        try_again or return false
      end
    end
  end

  def devices(range = nil)
    if range
      devices.select { |d| range.member?(d.number) }
    else
      ready?
      @devices.values
    end
  end

  def device(number)
    @devices[number] ||= SocketSwitcher::Device.new(self, number)
  end

  private

  def debug_output(message)
    if debug
      STDERR.puts message
    end
  end

  def set_state(device, state)
    request(device, state) do |response|
      case response
      when /^ACK/
        return true
      when /^RDY/
        try_again SocketSwitcher::TryAgainError.for_device(
          device, "not ready after #@attempt attempts"
        )
      when /^NAK device/
        raise SocketSwitcher::InvalidResponse.for_device(
          device, "invalid device number: #{device.number}")
      when /^NAK state/
        raise SocketSwitcher::InvalidResponse.for_device(
          device, "invalid state number: #{state}")
      else
        try_again SocketSwitcher::TryAgainError.for_device(
          device, "unexpected response #{response.inspect} after #@attempt attempts")
      end
    end
  end

  def synchronize(&block)
    @mutex.synchronize(&block)
  end

  def try_again(exception = nil)
    if @attempt < @attempts
      @attempt += 1
      sleep @timeout.to_f / 1000
      throw :again
    elsif exception
      raise exception
    else
      return false
    end
  end

  def set_timeout
    @serial_port.read_timeout = @timeout
    begin
      @serial_port.write_timeout = @timeout
    rescue NotImplementedError
    end
  end

  def request(device = nil, state = nil, &block)
    synchronize do
      begin
        @attempt = 1
        loop do
          set_timeout
          catch :again do
            query = ''
            device && state and query << "#{device.number} #{state}"
            query << "\r\n"
            debug_output "<< #{query.inspect}"
            @serial_port.print(query)
            unless response = @serial_port.gets
              try_again SocketSwitcher::TryAgainError.for_device(
                device, "timeout after #@attempt attempts"
              )
            end
            debug_output ">> #{response.inspect}"
            block[response]
          end
        end
      rescue => e
        unless SocketSwitcher::SocketSwitcherError === e
          e = SocketSwitcher::CommunicationError.wrap(device, e)
        end
        raise e
      end
    end
  end
end
