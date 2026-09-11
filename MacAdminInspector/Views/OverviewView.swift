import SwiftUI

struct OverviewView: View {
    private let device = DeviceInformationService().snapshot()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(device.name)
                            .font(.largeTitle.bold())
                    }
                }

                GroupBox("Mac at a glance") {
                    Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 12) {
                        row("Model", device.modelIdentifier)
                        row("Architecture", device.architecture)
                        if let rosettaInstalled = device.rosettaInstalled {
                            row("Rosetta 2", rosettaInstalled ? "Installed" : "Not installed")
                        }
                        row("Memory", ByteCountFormatter.string(fromByteCount: Int64(device.memoryBytes), countStyle: .memory))
                        row("Storage", storageDescription)
                        row("Serial number", device.serialNumber ?? "Unavailable")
                        row("macOS", macOSDescription)
                        row("Last restart", device.lastRestart.formatted(date: .abbreviated, time: .shortened))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }

                if let battery = device.battery {
                    GroupBox("Battery health") {
                        Grid(alignment: .leading, horizontalSpacing: 32, verticalSpacing: 12) {
                            row("Condition", battery.condition ?? "Unavailable")
                            row("Maximum capacity", battery.maximumCapacityPercent.map { "\($0)%" } ?? "Unavailable")
                            row("Cycle count", battery.cycleCount.map(String.init) ?? "Unavailable")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                    }
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Overview")
    }

    private var storageDescription: String {
        let total = ByteCountFormatter.string(fromByteCount: Int64(device.storage.totalBytes), countStyle: .file)
        let available = ByteCountFormatter.string(fromByteCount: Int64(device.storage.availableBytes), countStyle: .file)
        return "\(available) available of \(total)"
    }

    private var macOSDescription: String {
        [device.macOSVersion, device.macOSBuild.map { "Build \($0)" }]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    @ViewBuilder
    private func row(_ title: String, _ value: String) -> some View {
        GridRow {
            Text(title)
                .foregroundStyle(.secondary)
            Text(value)
                .textSelection(.enabled)
        }
    }
}
