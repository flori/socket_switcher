require 'spec_helper'

describe SocketSwitcher::Device do
  let :port do
    double('Port')
  end

  let :device do
    SocketSwitcher::Device.new(port, 23)
  end

  it 'knows about port' do
    expect(device.port).to eq port
  end

  it 'knows its own number' do
    expect(device.number).to eq 23
  end

  it 'sets state to 1 after receiving on' do
    expect(port).to receive(:set_state).with(device, 1)
    device.on
  end

  it 'sets state to 0 after receiving off' do
    expect(port).to receive(:set_state).with(device, 0)
    device.off
  end

  it 'has a nice #to_s' do
    expect(device.to_s).to eq '#<SocketSwitcher::Device number=23>'
  end

  it 'has a nice #inspect' do
    expect(device.inspect).to eq '#<SocketSwitcher::Device number=23>'
  end
end
