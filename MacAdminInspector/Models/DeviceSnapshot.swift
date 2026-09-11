import Foundation

struct DeviceSnapshot {
    let name: String
    let modelIdentifier: String
    let architecture: String
    let memoryBytes: UInt64
    let storage: StorageInfo
    let serialNumber: String?
    let macOSVersion: String
    let macOSBuild: String?
    let lastRestart: Date
    let rosettaInstalled: Bool?
    let battery: BatteryInfo?

    struct StorageInfo {
        let totalBytes: Int
        let availableBytes: Int
    }

    struct BatteryInfo {
        let condition: String?
        let maximumCapacityPercent: Int?
        let cycleCount: Int?
    }
}
