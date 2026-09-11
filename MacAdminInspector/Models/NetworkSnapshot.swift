import Foundation

struct NetworkSnapshot {
    let primaryInterfaceName: String?
    let connectionDNSServers: [String]
    let systemDNSServers: [String]
    let wifi: WiFi?
    let interfaces: [NetworkInterface]

    struct WiFi {
        let interfaceName: String
        let ssid: String?
        let bssid: String?
        let rssi: Int
        let noise: Int
        let channel: Int?
    }

    struct NetworkInterface: Identifiable {
        let name: String
        let isPrimary: Bool
        let ipv4Addresses: [String]
        let ipv6Addresses: [String]

        var id: String { name }
    }
}
