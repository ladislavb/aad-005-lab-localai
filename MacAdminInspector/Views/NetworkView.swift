import SwiftUI

struct NetworkView: View {
    @StateObject private var model = NetworkViewModel()

    private var network: NetworkSnapshot { model.snapshot }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                GroupBox("Public IP") {
                    Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 12) {
                        row("Address", publicIPAddressValue)
                        row("Source", "ifconfig.co/json")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }

                if let wifi = network.wifi {
                    GroupBox("Wi-Fi") {
                        Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 12) {
                            row("Interface", wifi.interfaceName)
                            row("SSID", wifi.ssid.orUnavailable)
                            row("BSSID", wifi.bssid.orUnavailable)
                            row("RSSI", "\(wifi.rssi) dBm")
                            row("Noise", "\(wifi.noise) dBm")
                            row("Channel", wifi.channel.map(String.init).orUnavailable)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)

                        if wifi.ssid == nil {
                            Text("macOS did not return Wi-Fi network details. SSID and BSSID require Location access.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                            Button("Allow access to Wi-Fi details") {
                                WiFiLocationAuthorizationService.shared.requestAccess()
                            }
                            .padding(.top, 8)
                        }
                    }
                }

                GroupBox("DNS") {
                    Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 12) {
                        row("Connection DNS", network.connectionDNSServers.joined(separator: ", ").orUnavailable)
                        row("System DNS", network.systemDNSServers.joined(separator: ", ").orUnavailable)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }

                GroupBox("Interfaces with assigned addresses (\(network.interfaces.count))") {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(network.interfaces) { interface in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "network")
                                    .frame(width: 20)
                                    .foregroundStyle(interface.isPrimary ? Color.accentColor : Color.secondary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(interface.name)\(interface.isPrimary ? " · Primary" : "")")
                                        .font(.headline)
                                    Text("IPv4: \(interface.ipv4Addresses.joined(separator: ", ").orUnavailable)")
                                    Text("IPv6: \(interface.ipv6Addresses.joined(separator: ", ").orUnavailable)")
                                }
                                .font(.caption)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            if interface.id != network.interfaces.last?.id {
                                Divider()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Network")
    }

    @ViewBuilder
    private func row(_ title: String, _ value: String) -> some View {
        GridRow {
            Text(title).foregroundStyle(.secondary)
            Text(value).textSelection(.enabled)
        }
    }

    private var publicIPAddressValue: String {
        if let address = model.publicIPAddress {
            return address
        }
        return model.hasCompletedPublicIPLookup ? "Unavailable" : "Loading…"
    }

}

private extension String {
    var orUnavailable: String { isEmpty ? "Unavailable" : self }
}

private extension Optional where Wrapped == String {
    var orUnavailable: String { self ?? "Unavailable" }
}
