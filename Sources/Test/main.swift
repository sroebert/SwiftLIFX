import SwiftLIFX
import Foundation

let macAddress = MacAddress(string: "D0:73:D5:22:88:5A")!
let light = LIFXLight(macAddress: macAddress)
let service = LIFXService(source: 0x726f6562)
// service.togglePowerState(for: light)
// service.setBrightness(0.5, for: light, duration: 1000)

do {
    let devices = try service.findDevices().wait()
    for device in devices {
        print("\(device.macAddress) (\(device.socketAddress?.description ?? ""))")
    }
} catch {
    print("Failed with error: \(error)")
}
