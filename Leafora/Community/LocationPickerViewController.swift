//
//  LocationPickerViewController.swift
//  Leafora
//

import UIKit
import MapKit
import CoreLocation

class LocationPickerViewController: UIViewController {

    var onLocationSelected: ((String, Double, Double) -> Void)?

    private let mapView = MKMapView()
    private let pinImageView = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
    private let addressLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Pick Location"
        
        // Navigation Bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        
        // MapView
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        // Pin Image
        pinImageView.tintColor = .systemRed // Standard pin color
        view.addSubview(pinImageView)
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Panel
        let panelView = UIView()
        panelView.backgroundColor = .systemBackground
        panelView.layer.cornerRadius = 16
        panelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(panelView)
        panelView.translatesAutoresizingMaskIntoConstraints = false
        
        addressLabel.text = "Loading address..."
        addressLabel.numberOfLines = 2
        addressLabel.textAlignment = .center
        addressLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        confirmButton.setTitle("Confirm Location", for: .normal)
        confirmButton.backgroundColor = UIColor(red: 0.17, green: 0.52, blue: 0.22, alpha: 1.0)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [addressLabel, confirmButton])
        stack.axis = .vertical
        stack.spacing = 16
        panelView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: panelView.topAnchor, constant: 20),
            
            pinImageView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            pinImageView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -15),
            pinImageView.widthAnchor.constraint(equalToConstant: 40),
            pinImageView.heightAnchor.constraint(equalToConstant: 40),
            
            panelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: panelView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: panelView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func confirmTapped() {
        let coordinate = mapView.centerCoordinate
        let name = addressLabel.text ?? "Selected Location"
        onLocationSelected?(name, coordinate.latitude, coordinate.longitude)
        dismiss(animated: true)
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Reverse geocode failed: \(error.localizedDescription)")
                self?.addressLabel.text = "Unknown Location"
                return
            }
            if let placemark = placemarks?.first {
                var addressParts: [String] = []
                if let name = placemark.name { addressParts.append(name) }
                if let locality = placemark.locality { addressParts.append(locality) }
                self?.addressLabel.text = addressParts.joined(separator: ", ")
            } else {
                self?.addressLabel.text = "Unknown Location"
            }
        }
    }
}

extension LocationPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        reverseGeocode(coordinate: mapView.centerCoordinate)
    }
}

extension LocationPickerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        manager.stopUpdatingLocation()
    }
}
