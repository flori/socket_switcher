class SocketSwitcher::Device
  def initialize(port, number)
    @port   = port
    @number = number
  end

  attr_reader :port

  attr_reader :number

  def on
    @port.__send__(:set_state, self, 1)
  end

  def off
    @port.__send__(:set_state, self, 0)
  end

  def to_s
    "#<#{self.class} number=#{number}>"
  end

  alias inspect to_s
end
