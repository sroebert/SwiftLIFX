import Foundation

struct LIFXMessageTypes {
    static let all: [LIFXMessage.Type] = [
        AcknowledgementLIFXMessage.self,
        
        GetServiceLIFXMessage.self,
        StateServiceLIFXMessage.self,
        
        GetHostInfoLIFXMessage.self,
        StateHostInfoLIFXMessage.self,
        GetHostFirmwareLIFXMessage.self,
        StateHostFirmwareLIFXMessage.self,
        
        GetWifiInfoLIFXMessage.self,
        StateWifiInfoLIFXMessage.self,
        GetWifiFirmwareLIFXMessage.self,
        StateWifiFirmwareLIFXMessage.self,
        
        GetPowerLIFXMessage.self,
        SetPowerLIFXMessage.self,
        StatePowerLIFXMessage.self,
        
        GetLabelLIFXMessage.self,
        SetLabelLIFXMessage.self,
        StateLabelLIFXMessage.self,
        
        GetVersionLIFXMessage.self,
        StateVersionLIFXMessage.self,
        
        GetInfoLIFXMessage.self,
        StateInfoLIFXMessage.self,
        
        GetLightStateLIFXMessage.self,
        StateLightLIFXMessage.self,
        SetLightColorLIFXMessage.self,
        
        GetPowerLightLIFXMessage.self,
        SetPowerLightLIFXMessage.self,
        StatePowerLightLIFXMessage.self,
    ]
    
    static let mapping: [UInt16:LIFXMessage.Type] = {
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
