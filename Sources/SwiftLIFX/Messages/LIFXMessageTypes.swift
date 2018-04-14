import Foundation

struct LIFXMessageTypes {
    static let all: [LIFXMessage.Type] = [
        AcknowledgementLIFXMessage.self,
        GetServiceLIFXMessage.self,
        StateServiceLIFXMessage.self,
        GetPowerLIFXMessage.self,
        SetPowerLIFXMessage.self,
        StatePowerLIFXMessage.self,
        
        GetLightStateLIFXMessage.self,
        StateLightLIFXMessage.self,
        SetLightColorLIFXMessage.self,
        GetPowerLightLIFXMessage.self,
        StatePowerLightLIFXMessage.self,
        SetPowerLightLIFXMessage.self,
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
