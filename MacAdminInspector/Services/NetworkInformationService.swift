import Darwin
import CoreWLAN
import Foundation
import SystemConfiguration

/// Reads active local network configuration without scanning or connecting to a network.
struct NetworkInformationService {
    func snapshot() -> NetworkSnapshot {
        let store = SCDynamicStoreCreate(nil, "MacAdminInspector" as CFString, nil, nil)
        let globalIPv4 = store.flatMap { value(at: "State:/Network/Global/IPv4", store: $0) }
        let primaryInterfaceName = globalIPv4?["PrimaryInterface"] as? String
        let primaryService = globalIPv4?["PrimaryService"] as? String
        let connectionDNS = primaryService.flatMap { serviceID in
            store.flatMap {
                value(at: "State:/Network/Service/\(serviceID)/DNS", store: $0)
                    ?? value(at: "Setup:/Network/Service/\(serviceID)/DNS", store: $0)
            }
        }
        let systemDNS = store.flatMap { value(at: "State:/Network/Global/DNS", store: $0) }

        return NetworkSnapshot(
            primaryInterfaceName: primaryInterfaceName,
            connectionDNSServers: (connectionDNS?["ServerAddresses"] as? [String]) ?? [],
            systemDNSServers: (systemDNS?["ServerAddresses"] as? [String]) ?? [],
            wifi: wifiConnection(),
            interfaces: activeInterfaces(primaryInterfaceName: primaryInterfaceName)
        )
    }

    private func wifiConnection() -> NetworkSnapshot.WiFi? {
        guard let interface = CWWiFiClient.shared().interface() else {
            return nil
        }

        return NetworkSnapshot.WiFi(
            interfaceName: interface.interfaceName ?? "Unavailable",
            ssid: interface.ssid(),
            bssid: interface.bssid(),
            rssi: interface.rssiValue(),
            noise: interface.noiseMeasurement(),
            channel: interface.wlanChannel()?.channelNumber
        )
    }

    private func value(at path: String, store: SCDynamicStore) -> [String: Any]? {
        SCDynamicStoreCopyValue(store, path as CFString) as? [String: Any]
    }

    private func activeInterfaces(primaryInterfaceName: String?) -> [NetworkSnapshot.NetworkInterface] {
        var firstInterface: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&firstInterface) == 0, let firstInterface else { return [] }
        defer { freeifaddrs(firstInterface) }

        struct Record {
            let name: String
            var ipv4Addresses: [String] = []
            var ipv6Addresses: [String] = []
        }

        var records: [String: Record] = [:]
        var current: UnsafeMutablePointer<ifaddrs>? = firstInterface

        while let interface = current {
            defer { current = interface.pointee.ifa_next }
            let name = String(cString: interface.pointee.ifa_name)
            let flags = Int32(interface.pointee.ifa_flags)
            guard name != "lo0", flags & IFF_UP != 0, flags & IFF_RUNNING != 0 else { continue }

            var record = records[name] ?? Record(name: name)
            if let address = interface.pointee.ifa_addr, let numericAddress = numericAddress(for: address) {
                switch address.pointee.sa_family {
                case UInt8(AF_INET):
                    record.ipv4Addresses.append(numericAddress)
                case UInt8(AF_INET6):
                    record.ipv6Addresses.append(numericAddress)
                default:
                    break
                }
            }
            records[name] = record
        }

        return records.values.compactMap { record in
            let usableIPv4 = record.ipv4Addresses.filter { !$0.hasPrefix("127.") }
            let usableIPv6 = record.ipv6Addresses.filter { !$0.lowercased().hasPrefix("fe80:") }
            let isPrimary = record.name == primaryInterfaceName
            guard isPrimary || !usableIPv4.isEmpty || !usableIPv6.isEmpty else { return nil }

            return NetworkSnapshot.NetworkInterface(
                name: record.name,
                isPrimary: isPrimary,
                ipv4Addresses: usableIPv4.sorted(),
                ipv6Addresses: usableIPv6.sorted()
            )
        }
        .sorted {
            if $0.isPrimary != $1.isPrimary { return $0.isPrimary }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    private func numericAddress(for address: UnsafeMutablePointer<sockaddr>) -> String? {
        var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let result = getnameinfo(
            address,
            socklen_t(address.pointee.sa_len),
            &host,
            socklen_t(host.count),
            nil,
            0,
            NI_NUMERICHOST
        )
        return result == 0 ? String(cString: host) : nil
    }
}
