import Foundation

/// Fetches the public address reported by the user-approved ifconfig.co endpoint.
struct PublicIPInformationService: Sendable {
    func address() -> String? {
        let process = Process()
        let output = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
        process.arguments = [
            "--fail",
            "--silent",
            "--show-error",
            "--connect-timeout", "3",
            "--max-time", "5",
            "https://ifconfig.co/json"
        ]
        process.standardOutput = output

        guard (try? process.run()) != nil else { return nil }
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return nil }

        let data = output.fileHandleForReading.readDataToEndOfFile()
        return (try? JSONDecoder().decode(Response.self, from: data))?.ip
    }

    private struct Response: Decodable {
        let ip: String
    }
}
