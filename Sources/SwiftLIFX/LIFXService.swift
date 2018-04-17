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
        return client.send(GetServiceLIFXMessage(), responseType: StateServiceLIFXMessage.self, timeout: timeout).map { responses in
            responses.compactMap { $0.device }
        }
    }
    
    // MARK: - Power
    
    public func getPowerState(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.PowerState> {
        return client.send(GetPowerLIFXMessage(), for: device, responseType: StatePowerLIFXMessage.self, timeout: timeout).map { response in
            return response.message.powerState
        }
    }
    
    @discardableResult
    public func setPowerState(_ powerState: LIFXDevice.PowerState, for device: LIFXDevice? = nil) -> EventLoopFuture<Void> {
        return client.send(SetPowerLIFXMessage(powerState: powerState), for: device)
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
        return client.send(GetHostFirmwareLIFXMessage(), for: device, responseType: StateHostFirmwareLIFXMessage.self, timeout: timeout).map { response in
            return response.message.firmware
        }
    }
    
    public func getWifiFirmware(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.Firmware> {
        return client.send(GetWifiFirmwareLIFXMessage(), for: device, responseType: StateWifiFirmwareLIFXMessage.self, timeout: timeout).map { response in
            return response.message.firmware
        }
    }
    
    public func getVersion(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.Version> {
        return client.send(GetVersionLIFXMessage(), for: device, responseType: StateVersionLIFXMessage.self, timeout: timeout).map { response in
            return response.message.version
        }
    }
    
    // MARK: - Lights
    
    public func getState(for light: LIFXLight) -> EventLoopFuture<LIFXLight.State> {
        return client.send(GetLightStateLIFXMessage(), for: light, responseType: StateLightLIFXMessage.self, timeout: timeout).map { response in
            let message = response.message
            return LIFXLight.State(color: message.color, powerState: message.powerState, label: message.label)
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
        return client.send(SetLightColorLIFXMessage(color: color, duration: duration), for: light)
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
