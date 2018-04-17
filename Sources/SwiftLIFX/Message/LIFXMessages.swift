import Foundation

public struct LIFXMessages {
    public static let all: [LIFXMessage.Type] = [
        Acknowledgement.self,
        
        GetService.self,
        StateService.self,
        
        GetHostInfo.self,
        StateHostInfo.self,
        GetHostFirmware.self,
        StateHostFirmware.self,
        
        GetWifiInfo.self,
        StateWifiInfo.self,
        GetWifiFirmware.self,
        StateWifiFirmware.self,
        
        GetPower.self,
        SetPower.self,
        StatePower.self,
        
        GetLabel.self,
        SetLabel.self,
        StateLabel.self,
        
        GetVersion.self,
        StateVersion.self,
        
        GetInfo.self,
        StateInfo.self,
        
        GetLightState.self,
        StateLight.self,
        SetLightColor.self,
        
        GetPowerLight.self,
        SetPowerLight.self,
        StatePowerLight.self,
    ]
    
    public static let mapping: [UInt16:LIFXMessage.Type] = {
        var mapping: [UInt16:LIFXMessage.Type] = [:]
        for type in all {
            guard mapping[type.id] == nil else {
                fatalError("Duplicate message id: \(type.id).")
            }
            mapping[type.id] = type
        }
        return mapping
    }()
}
