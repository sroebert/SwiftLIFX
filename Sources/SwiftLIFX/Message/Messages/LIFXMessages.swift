import Foundation

public struct LIFXMessages {
    
    // MARK: - Mapping
    
    static let mapping: [UInt16: LIFXMessage.Type] = [
        002: GetService.self,
        003: StateService.self,
        
        012: GetHostInfo.self,
        013: StateHostInfo.self,
        014: GetHostFirmware.self,
        015: StateHostFirmware.self,
        
        016: GetWifiInfo.self,
        017: StateWifiInfo.self,
        018: GetWifiFirmware.self,
        019: StateWifiFirmware.self,
        
        020: GetPower.self,
        021: SetPower.self,
        022: StatePower.self,
        
        023: GetLabel.self,
        024: SetLabel.self,
        025: StateLabel.self,
        
        032: GetVersion.self,
        033: StateVersion.self,
        
        034: GetInfo.self,
        035: StateInfo.self,
        
        045: Acknowledgement.self,
        
        101: LightGet.self,
        102: LightSetColor.self,
        107: LightState.self,
        
        116: LightGetPower.self,
        117: LightSetPower.self,
        118: LightStatePower.self,
    ]
    
    private static let inverseMapping: [ObjectIdentifier: UInt16] = {
        var inverseMapping: [ObjectIdentifier: UInt16] = [:]
        for (id, type) in mapping {
            inverseMapping[ObjectIdentifier(type)] = id
        }
        return inverseMapping
    }()
    
    static func getType(for message: LIFXMessage.Type) -> UInt16? {
        return inverseMapping[ObjectIdentifier(message)]
    }
}
