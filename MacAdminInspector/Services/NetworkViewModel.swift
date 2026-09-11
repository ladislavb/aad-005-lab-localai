import Combine
@preconcurrency import Foundation

@MainActor
final class NetworkViewModel: ObservableObject {
    @Published private(set) var snapshot = NetworkInformationService().snapshot()
    @Published private(set) var publicIPAddress: String?
    @Published private(set) var hasCompletedPublicIPLookup = false

    private var authorizationObserver: NSObjectProtocol?

    init() {
        authorizationObserver = NotificationCenter.default.addObserver(
            forName: .wifiLocationAuthorizationChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
        fetchPublicIPAddress()
    }

    deinit {
        if let authorizationObserver {
            NotificationCenter.default.removeObserver(authorizationObserver)
        }
    }

    func refresh() {
        snapshot = NetworkInformationService().snapshot()
    }

    private func fetchPublicIPAddress() {
        Task { [weak self] in
            let address = await Task.detached(priority: .utility) {
                PublicIPInformationService().address()
            }.value

            self?.publicIPAddress = address
            self?.hasCompletedPublicIPLookup = true
        }
    }
}
