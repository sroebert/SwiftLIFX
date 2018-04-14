import Foundation
import NIO

public class LIFXService {
    
    // MARK: - Properties
    
    public let source: UInt32
    public var timeout: TimeAmount
    
    // MARK: - Init
    
    public init(source: UInt32, timeout: TimeAmount = .seconds(2)) {
        self.source = source
        self.timeout = timeout
    }
    
    // MARK: - Devices
    
    public func findDevices() -> EventLoopFuture<[LIFXDevice]> {
        return LIFXMessageClient.send(GetServiceLIFXMessage(), source: source, responseType: StateServiceLIFXMessage.self, timeout: timeout).map { responses in
            responses.compactMap { $0.device }
        }
    }
    
    // MARK: - Power
    
    public func getPowerState(for device: LIFXDevice) -> EventLoopFuture<LIFXDevice.PowerState> {
        return LIFXMessageClient.send(GetPowerLIFXMessage(), for: device, source: source, responseType: StatePowerLIFXMessage.self, timeout: timeout).map { response in
            return response.message.powerState
        }
    }
    
    @discardableResult
    public func setPowerState(_ powerState: LIFXDevice.PowerState, for device: LIFXDevice) -> EventLoopFuture<Void> {
        return LIFXMessageClient.send(SetPowerLIFXMessage(powerState: powerState), for: device, source: source)
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
    
    // MARK: - Lights
    
    public func getState(for light: LIFXLight) -> EventLoopFuture<LIFXLight.State> {
        return LIFXMessageClient.send(GetLightStateLIFXMessage(), for: light, source: source, responseType: StateLightLIFXMessage.self, timeout: timeout).map { response in
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
    public func setColor(_ color: LIFXLight.Color, for light: LIFXLight, duration: UInt32 = 0) -> EventLoopFuture<Void> {
        return LIFXMessageClient.send(SetLightColorLIFXMessage(color: color, duration: duration), for: light, source: source)
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
