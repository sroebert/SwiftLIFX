import Foundation
import NIO

public class LIFXService {
    
    // MARK: - Properties
    
    public let source: UInt32
    public var timeout: TimeAmount
    
    private let client: LIFXClient
    
    // MARK: - Init
    
    public init(source: UInt32, timeout: TimeAmount = .seconds(1)) {
        self.source = source
        self.timeout = timeout
        client = LIFXClient(source: source)
    }
    
    // MARK: - Devices
    
    public func findDevices() -> EventLoopFuture<[LIFXDevice]> {
        return client.send(LIFXMessages.GetService(), responseType: LIFXMessages.StateService.self, timeout: timeout).map { responses in
            responses.compactMap { $0.device }
        }
    }
    
    // MARK: - Power
    
    public func getPowerState(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.PowerState> {
        return client.send(LIFXMessages.GetPower(), for: device, responseType: LIFXMessages.StatePower.self, timeout: timeout).map { response in
            return response.message.powerState
        }
    }
    
    @discardableResult
    public func setPowerState(_ powerState: LIFXDevice.PowerState, for device: LIFXDevice? = nil) -> EventLoopFuture<Void> {
        return client.send(LIFXMessages.SetPower(powerState: powerState), for: device)
    }
    
    @discardableResult
    public func togglePowerState(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.PowerState> {
        return getPowerState(for: device).then { powerState in
            let toggled = powerState.toggled
            return self.setPowerState(toggled, for: device).map {
                return toggled
            }
        }
    }
    
    // MARK: - Info
    
    public func getHostFirmware(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.Firmware> {
        return client.send(LIFXMessages.GetHostFirmware(), for: device, responseType: LIFXMessages.StateHostFirmware.self, timeout: timeout).map { response in
            return response.message.firmware
        }
    }
    
    public func getWifiFirmware(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.Firmware> {
        return client.send(LIFXMessages.GetWifiFirmware(), for: device, responseType: LIFXMessages.StateWifiFirmware.self, timeout: timeout).map { response in
            return response.message.firmware
        }
    }
    
    public func getVersion(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.Version> {
        return client.send(LIFXMessages.GetVersion(), for: device, responseType: LIFXMessages.StateVersion.self, timeout: timeout).map { response in
            return response.message.version
        }
    }
    
    // MARK: - Lights
    
    public func getState(for light: LIFXLight) -> EventLoopFuture<LIFXLight.State> {
        return client.send(LIFXMessages.LightGet(), for: light, responseType: LIFXMessages.LightState.self, timeout: timeout).map { response in
            let message = response.message
            return message.state
        }
    }
    
    public func getColor(for light: LIFXLight) -> EventLoopFuture<LIFXLight.Color> {
        return getState(for: light).map { $0.color }
    }
    
    public func getLabel(for light: LIFXLight) -> EventLoopFuture<String> {
        return getState(for: light).map { $0.label }
    }
    
    @discardableResult
    public func setColor(_ color: LIFXLight.Color, for light: LIFXLight? = nil, duration: UInt32 = 0) -> EventLoopFuture<Void> {
        return client.send(LIFXMessages.LightSetColor(color: color, duration: duration), for: light)
    }
    
    @discardableResult
    public func setBrightness(_ percentage: Float, for light: LIFXLight, duration: UInt32 = 0) -> EventLoopFuture<Void> {
        return getColor(for: light).then { color in
            var newColor = color
            newColor.brightnessPercentage = percentage
            return self.setColor(newColor, for: light, duration: duration)
        }
    }
}
