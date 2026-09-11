import CoreLocation
import Foundation

extension Notification.Name {
    static let wifiLocationAuthorizationChanged = Notification.Name("wifiLocationAuthorizationChanged")
}

@MainActor
final class WiFiLocationAuthorizationService: NSObject, CLLocationManagerDelegate {
    static let shared = WiFiLocationAuthorizationService()
    private let locationManager = CLLocationManager()

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestAccess() {
        locationManager.requestWhenInUseAuthorization()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .wifiLocationAuthorizationChanged, object: nil)
        }
    }
}
