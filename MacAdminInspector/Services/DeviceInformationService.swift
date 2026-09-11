import Darwin
import Foundation
import IOKit

/// Collects a small, local-only device profile without changing system state.
struct DeviceInformationService {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func snapshot() -> DeviceSnapshot {
        let isAppleSilicon = integerValue(for: "hw.optional.arm64") == 1
        let systemVersion = systemVersionInfo()

        return DeviceSnapshot(
            name: Host.current().localizedName ?? ProcessInfo.processInfo.hostName,
            modelIdentifier: stringValue(for: "hw.model") ?? "Unknown model",
            architecture: isAppleSilicon ? "Apple Silicon" : "Intel",
            memoryBytes: ProcessInfo.processInfo.physicalMemory,
            storage: storageInfo(),
            serialNumber: serialNumber(),
            macOSVersion: systemVersion.version,
            macOSBuild: systemVersion.build,
            lastRestart: .now.addingTimeInterval(-ProcessInfo.processInfo.systemUptime),
            rosettaInstalled: isAppleSilicon ? fileManager.fileExists(atPath: "/Library/Apple/usr/libexec/oahd") : nil,
            battery: batteryInfo()
        )
    }

    private func storageInfo() -> DeviceSnapshot.StorageInfo {
        let rootVolume = URL(fileURLWithPath: "/", isDirectory: true)
        let values = try? rootVolume.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
        return DeviceSnapshot.StorageInfo(
            totalBytes: values?.volumeTotalCapacity ?? 0,
            availableBytes: values?.volumeAvailableCapacity ?? 0
        )
    }

    private func systemVersionInfo() -> (version: String, build: String?) {
        let url = URL(fileURLWithPath: "/System/Library/CoreServices/SystemVersion.plist")
        guard let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else { return (ProcessInfo.processInfo.operatingSystemVersionString, nil) }

        return (
            plist["ProductVersion"] as? String ?? ProcessInfo.processInfo.operatingSystemVersionString,
            plist["ProductBuildVersion"] as? String
        )
    }

    private func serialNumber() -> String? {
        let matching = IOServiceMatching("IOPlatformExpertDevice")
        let service = IOServiceGetMatchingService(kIOMainPortDefault, matching)
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }

        return IORegistryEntryCreateCFProperty(
            service,
            "IOPlatformSerialNumber" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? String
    }

    private func batteryInfo() -> DeviceSnapshot.BatteryInfo? {
        let process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        process.arguments = ["SPPowerDataType", "-json"]
        process.standardOutput = output

        guard (try? process.run()) != nil else { return nil }
        process.waitUntilExit()
        guard process.terminationStatus == 0,
              let json = try? JSONSerialization.jsonObject(with: output.fileHandleForReading.readDataToEndOfFile()),
              let health = findBatteryHealth(in: json)
        else { return nil }

        let rawCondition = health["sppower_battery_health"] as? String
        let capacityText = health["sppower_battery_health_maximum_capacity"] as? String
        let capacity = capacityText.flatMap { Int($0.filter(\.isNumber)) }
        let cycleCount = (health["sppower_battery_cycle_count"] as? NSNumber)?.intValue
            ?? (health["sppower_battery_cycle_count"] as? String).flatMap(Int.init)

        return DeviceSnapshot.BatteryInfo(
            condition: rawCondition.map { $0 == "Good" ? "Normal" : $0 },
            maximumCapacityPercent: capacity,
            cycleCount: cycleCount
        )
    }

    private func findBatteryHealth(in object: Any) -> [String: Any]? {
        if let dictionary = object as? [String: Any] {
            if let health = dictionary["sppower_battery_health_info"] as? [String: Any] {
                return health
            }
            return dictionary.values.lazy.compactMap(findBatteryHealth(in:)).first
        }
        if let array = object as? [Any] {
            return array.lazy.compactMap(findBatteryHealth(in:)).first
        }
        return nil
    }

    private func stringValue(for name: String) -> String? {
        var size: size_t = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else { return nil }

        var buffer = [CChar](repeating: 0, count: Int(size))
        let result = buffer.withUnsafeMutableBytes { bytes in
            sysctlbyname(name, bytes.baseAddress, &size, nil, 0)
        }
        return result == 0 ? String(cString: buffer) : nil
    }

    private func integerValue(for name: String) -> Int32? {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        return sysctlbyname(name, &value, &size, nil, 0) == 0 ? value : nil
    }
}
