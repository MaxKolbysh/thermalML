//
//  LocationManager.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import CoreLocation
import Combine

struct LocationModel: Equatable {
    var city: String
    var country: String
    var coordinates: CLLocationCoordinate2D
}

class LocationManager: NSObject, ObservableObject {
    @Published var location: LocationModel?
    @Published var error: Error?
    @Published var isLoading: Bool = false

    private var locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
    }

    private func reverseGeocodeLocation(_ location: CLLocation) {
        Task {
            do {
                let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
                if let placemark = placemarks.first {
                    let cityName = placemark.locality ?? ""
                    let countryName = placemark.country ?? ""
                    let coordinates = location.coordinate

                    await MainActor.run {
                        self.location = LocationModel(city: cityName, country: countryName, coordinates: coordinates)
                    }
                }
            } catch {
                // TODO: Handle error
                print("Error: \(error.localizedDescription)")
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task {
            handleLocationUpdate(locations)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task {
            await handleLocationError(error)
        }
    }

    private func handleLocationUpdate(_ locations: [CLLocation]) {
        if let location = locations.last {
            reverseGeocodeLocation(location)
            isLoading = false
        }
    }

    private func handleLocationError(_ error: Error) async {
        if let clError = error as? CLError, clError.code == .locationUnknown {
            do {
                try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            requestLocation()
        }

        isLoading = false
        self.error = error
    }
}

extension LocationModel {
    static func == (lhs: LocationModel, rhs: LocationModel) -> Bool {
        return lhs.city == rhs.city
    }
}
