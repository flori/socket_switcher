require 'spec_helper'

describe SocketSwitcher::Port do
  let :serial_port do
    double('SerialPort').tap do |sp|
      allow(sp).to receive(:read_timeout=)
      allow(sp).to receive(:write_timeout=)
      allow(sp).to receive(:print).with("\r\n")
    end
  end

  before do
    allow(SerialPort).to receive(:new).and_return serial_port
  end

  let :port do
    SocketSwitcher::Port.new('foo')
  end

  context 'instantiation and configuration' do
    it 'can be instantiated' do
      expect(port).to be_a SocketSwitcher::Port
      expect(port.debug).to eq false
      expect(port.timeout).to eq 2_000
    end

    it 'can be instantiated in debugging mode' do
      expect(SocketSwitcher::Port.new('foo', debug: true).debug).to eq true
    end

    it 'has a configurable debugging mode' do
      port.debug = true
      expect(port.debug).to eq true
    end

    it 'can be instantiated with a timeout' do
      expect(SocketSwitcher::Port.new('foo', timeout: 666).timeout).to eq 666
    end

    it 'has a configurable timeout' do
      port.timeout = 4_000
      expect(port.timeout).to eq 4_000
    end

    it 'wraps all unknown errors in SocketSwitcher::CommunicationError' do
      expect(SerialPort).to receive(:new).and_raise(Errno::ENXIO)
      expect { port }.to raise_error SocketSwitcher::CommunicationError
    end
  end

  describe '#ready?' do
    context 'sucessfull' do
      before do
        allow(serial_port).to receive(:gets).and_return("RDY 0 3\r\n")
      end

      it 'can query the ready state' do
        expect(port).to be_ready
      end

      context 'with debugging' do
        let :port do
          SocketSwitcher::Port.new('foo', debug: true)
        end

        it 'can query the ready state with debugging' do
          expect(STDERR).to receive(:puts).at_least(1)
          expect(port).to receive(:debug_output).with('<< "\r\n"').and_call_original
          expect(port).to receive(:debug_output).with('>> "RDY 0 3\r\n"').and_call_original
          expect(port).to be_ready
        end
      end
    end

    context 'some problem' do
      it 'does not handle too many garbled responses, but returns false' do
        expect(serial_port).to receive(:print).with("\r\n").at_least(1)
        expect(serial_port).to receive(:gets).and_return("RD…garbled…").at_least(1)
        expect(port).to receive(:sleep).with(port.timeout.to_f / 1000).at_least(1)
        expect(port).not_to be_ready
      end
    end
  end

  context 'timeout' do
    let :serial_port do
      double('SerialPort').tap do |sp|
        allow(sp).to receive(:print).with("\r\n")
        allow(sp).to receive(:gets).and_return("RDY 0 3\r\n")
      end
    end

    it 'sets the read_timeout and write_timeout' do
      expect(serial_port).to receive(:read_timeout=)
      expect(serial_port).to receive(:write_timeout=)
      expect(port).to be_ready
    end

    it 'ingores not implemented write_timeout' do
      expect(serial_port).to receive(:read_timeout=)
      expect(serial_port).to receive(:write_timeout=).and_raise(NotImplementedError)
      expect(port).to be_ready
    end
  end

  describe '#devices' do
    context 'successful' do
      before do
        allow(serial_port).to receive(:gets).and_return("RDY 0 3\r\n")
      end

      it 'returns all supported devices' do
        expect(port.devices.size).to eq 4
      end

      it 'can return a range of devices' do
        expect(port.devices(0..1).size).to eq 2
        expect(port.devices([0, 3]).size).to eq 2
      end
    end

    context 'some problem' do
      it 'returns all supported devices' do
        expect(serial_port).to receive(:gets).and_return("RD…garbled…")
        expect(serial_port).to receive(:gets).and_return("RDY 0 3\r\n")
        expect(port).to receive(:sleep).with(port.timeout.to_f / 1000)
        expect(port).to receive(:try_again).and_call_original
        expect(port.devices.size).to eq 4
      end
    end
  end

  describe '#device' do
    let :device do
      port.device(23)
    end

    it 'returns a device for number' do
      expect(device.number).to eq 23
    end

    it 'can be switched on' do
      expect(serial_port).to receive(:print).with("23 1\r\n")
      expect(serial_port).to receive(:gets).and_return("ACK\r\n")
      expect(device.on).to eq true
    end

    it 'can be switched off' do
      expect(serial_port).to receive(:print).with("23 0\r\n")
      expect(serial_port).to receive(:gets).and_return("ACK\r\n")
      expect(device.off).to eq true
    end

    it 'throws exceptions for device errors' do
      expect(serial_port).to receive(:print).with("23 0\r\n")
      expect(serial_port).to receive(:gets).and_return("NAK device\r\n")
      expect { device.off }.to raise_error SocketSwitcher::InvalidResponse
    end

    it 'throws exceptions for state errors' do
      expect(serial_port).to receive(:print).with("23 1\r\n")
      expect(serial_port).to receive(:gets).and_return("NAK state\r\n")
      expect { device.on }.to raise_error SocketSwitcher::InvalidResponse
    end

    it 'handles some garbled responses' do
      expect(serial_port).to receive(:print).with("23 1\r\n").twice
      expect(serial_port).to receive(:gets).and_return("RD…garbled…")
      expect(port).to receive(:sleep).with(port.timeout.to_f / 1000)
      expect(serial_port).to receive(:gets).and_return("ACK\r\n")
      expect(device.on).to eq true
    end

    it 'does not handle too many unexpected responses' do
      expect(serial_port).to receive(:print).with("23 1\r\n").at_least(1)
      expect(serial_port).to receive(:gets).and_return("RD…garbled…").at_least(1)
      expect(port).to receive(:sleep).with(port.timeout.to_f / 1000).at_least(1)
      expect { device.on }.to raise_error SocketSwitcher::TryAgainError
    end

    it 'can handle some ready responses' do
      expect(serial_port).to receive(:print).with("23 0\r\n").twice
      expect(serial_port).to receive(:gets).and_return("RDY 0 3\r\n")
      expect(port).to receive(:sleep).with(port.timeout.to_f / 1000)
      expect(serial_port).to receive(:gets).and_return("ACK\r\n")
      expect(device.off).to eq true
    end

    it 'does not handle too many ready responses' do
      expect(serial_port).to receive(:print).with("23 0\r\n").at_least(1)
      expect(serial_port).to receive(:gets).and_return("RDY 0 3\r\n").at_least(1)
      expect(port).to receive(:sleep).with(port.timeout.to_f / 1000).at_least(1)
      expect { device.off }.to raise_error SocketSwitcher::TryAgainError
    end

    it 'can handle some timeouts' do
      expect(serial_port).to receive(:print).with("23 0\r\n").twice
      expect(serial_port).to receive(:gets).and_return(nil)
      expect(port).to receive(:sleep).with(port.timeout.to_f / 1000)
      expect(serial_port).to receive(:gets).and_return("ACK\r\n")
      expect(device.off).to eq true
    end

    it 'does not handle too many ready responses' do
      expect(serial_port).to receive(:print).with("23 0\r\n").at_least(1)
      expect(serial_port).to receive(:gets).and_return(nil).at_least(1)
      expect(port).to receive(:sleep).with(port.timeout.to_f / 1000).at_least(1)
      expect { device.off }.to raise_error SocketSwitcher::TryAgainError
    end

    it 'wraps all unknown errors in SocketSwitcher::CommunicationError' do
      expect(serial_port).to receive(:print).and_raise(Errno::ENXIO)
      expect { device.on }.to raise_error SocketSwitcher::CommunicationError
    end
  end
end
