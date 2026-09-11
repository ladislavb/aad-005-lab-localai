# Mac Admin Inspector

Mac Admin Inspector is a deliberately small, local-first macOS inventory starter for the **Apple Admin Days** hands-on lab. Participants use an AI coding assistant to extend a SwiftUI device profile with focused, read-only inventory features.

## What is included

- A macOS 14+ SwiftUI app with Overview and Network screens.
- A local, read-only device profile: Mac name, model identifier, architecture, memory, storage, serial number, macOS version/build, uptime, Rosetta 2, and battery health when available.
- Read-only Network inventory: active interfaces, IP addresses, connection and system DNS, and Wi-Fi SSID when macOS makes it available.
- Focused Foundation services; views contain no filesystem or system-query logic.

The starter deliberately does **not** collect security, AI-tool, MCP, or reporting data. `Resources/AITools.json` is included as a data-only catalog for the AI Tools exercise.

## Open and run

1. Open [MacAdminInspector.xcodeproj](MacAdminInspector.xcodeproj) in Xcode 16 or later.
2. Select **My Mac** and press Run.

No administrator privileges, network access, telemetry, or external account are required.

## Lab

### Goal

Turn the small SwiftUI device profile into a useful local Mac inventory tool with an AI coding assistant. The starter provides a read-only device overview; each capability below is a focused exercise.

### Starting point

Run the app and inspect **Overview** and **Network**. They show basic device hardware, macOS, uptime, Rosetta 2 on Apple Silicon, battery health on portable Macs, and active network configuration.

### Suggested exercises

1. Add Security inventory for FileVault, SIP, Gatekeeper, firewall, and MDM enrollment. Keep checks local and read-only.
2. Add AI Tools using the prepared `Resources/AITools.json` catalog, then add GUI, CLI, and running-process discovery.
3. Add MCP configuration inventory. Redact secrets, headers, environment values, and tokens.
4. Add an exportable JSON report that the user explicitly chooses to save.

### Prompts worth trying

> Read the project and describe how the device profile flows from the service to the Overview. Do not edit files yet.

> Add Security inventory as a read-only service. Explain which checks require elevated permissions before implementation.

> Add an AI tool catalog and CLI scanner. It must avoid shell interpolation and identify the source of each detection.

### Definition of done

- The app builds for **My Mac**.
- Inventory remains local and read-only.
- User-visible text says what was detected and how.
- Each new source of inventory has a focused Foundation service.

### Reset points

Commit a checkpoint before each exercise. If an experiment goes sideways, return to the last checkpoint rather than trying to salvage unrelated changes.

## Privacy and safety

Inventory remains on the Mac. New features should be local and read-only, must not upload data or alter device configuration, and must not expose credentials from configuration files.

## License

MIT — see [LICENSE](LICENSE).
