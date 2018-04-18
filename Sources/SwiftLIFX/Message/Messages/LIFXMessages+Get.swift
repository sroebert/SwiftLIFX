import Foundation

extension LIFXMessages {
    public final class Acknowledgement: EmptyPayloadLIFXMessage {}
    
    public final class GetService: EmptyPayloadLIFXMessage {}
    public final class GetHostInfo: EmptyPayloadLIFXMessage {}
    public final class GetHostFirmware: EmptyPayloadLIFXMessage {}
    public final class GetWifiInfo: EmptyPayloadLIFXMessage {}
    public final class GetWifiFirmware: EmptyPayloadLIFXMessage {}
    public final class GetVersion: EmptyPayloadLIFXMessage {}
    public final class GetInfo: EmptyPayloadLIFXMessage {}
    public final class GetPower: EmptyPayloadLIFXMessage {}
    public final class GetLabel: EmptyPayloadLIFXMessage {}
    
    public final class LightGet: EmptyPayloadLIFXMessage {}
    public final class LightGetPower: EmptyPayloadLIFXMessage {}
}
