//
//  NearbyViewController.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/31/20.
//

import Foundation
import UIKit
import CoreLocation

class NearbyViewController: UITableViewController, CLLocationManagerDelegate {
    var selectedBird: Bird? = nil
    var locationManager = CLLocationManager()
    var emptyMessage = ""
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    var settingsButton = UIButton()
    var observations: [Observation]?
    var gotLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        locationManager.delegate = self
        locationManager(locationManager, didChangeAuthorization: locationManager.authorizationStatus)
        self.view.addSubview(self.activityIndicator)
        title = "Nearby"
        navigationItem.title = "Recent Sightings Near You"
        tableView.reloadData()

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let observations = self.observations else {
            tableView.setEmptyMessage(emptyMessage)
            return 0
        }
        if (observations.count == 0) {
            tableView.setEmptyMessage("No bird sightings were reported nearby recently")
        }
        else {
            tableView.restore()
        }
        return observations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> BirdCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BirdCell", for: indexPath) as! BirdCell
        guard let observations = self.observations else {
            return cell
        }
        let observation = observations[indexPath.row]
        cell.birdName.text = observation.comName
        cell.name = observation.comName
        let bird = BirdDataService.shared.birdsBySpeciesCode[observation.speciesCode]!
        PhotoDataService.shared.getPhotoURL(birds: [bird], size: "q") { url in
            guard let url = url, cell.name == bird.comName else { return }
            cell.url = url
            cell.request = DataService.shared.request(url) { data, request in
                cell.request = nil
                guard let data = data, cell.name == bird.comName else { return }
                DispatchQueue.main.async {
                    cell.birdPhoto.image = UIImage(data: data)?.cropMargins()
                }
            }
        }
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityIndicator.center = self.view.center
    }

    
    @objc func settingsButtonAction(_ sender:UIButton!) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
                self.settingsButton.isHidden = true
                switch status {
                case .notDetermined:
                    if !self.gotLocation {
                        manager.requestWhenInUseAuthorization()
                    }
                case .restricted, .denied:
                    self.emptyMessage = "To view recent sightings near you,\nplease allow location access in\n\nSettings › Privacy › Location\nServices › Happy Bird" 
                    DispatchQueue.main.async { [self] in
                        self.tableView.reloadData()
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else {
                            return
                        }
                        settingsButton = UIButton(type: .system)
                        settingsButton.frame = CGRect(x: self.view.bounds.width/2 - 100, y: self.view.bounds.height/2, width: 200, height: 50)
                        settingsButton.setTitle("Open Settings", for: .normal)
                        settingsButton.addTarget(self, action: #selector(settingsButtonAction(_:)), for: .touchUpInside)
                        self.view.addSubview(settingsButton)
                    }
                    break 
                case .authorizedAlways, .authorizedWhenInUse:
                    let reason = ["Satelites must be bird-watching", "Birds might be jamming the signal"].randomElement()! 
                    self.emptyMessage = "Waiting for location...\n(\(reason))"
                    DispatchQueue.main.async {
                        self.activityIndicator.startAnimating()
                        self.tableView.reloadData()
                    }
                    manager.requestLocation()
                    break
                @unknown default:
                    break
                }
            }

    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                    completionHandler(nil)
                }
            })
        }
        else {
            completionHandler(nil)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                print("Found user's location: \(location)")
                UserDefaults.standard.setValue(Float(location.coordinate.latitude), forKey: "lat")
                UserDefaults.standard.setValue(Float(location.coordinate.longitude), forKey: "lng")
                self.gotLocation = true
                BirdDataService.shared.lat = Float(location.coordinate.latitude)
                BirdDataService.shared.lng = Float(location.coordinate.longitude)
                self.lookUpCurrentLocation() { placemark in
                    if let placeName = placemark?.name  {
                        DispatchQueue.main.async { [self] in
                            navigationItem.title = "Recent Sightings Near \(placeName)"
                            tableView.reloadData()
                        }
                    }
                }
                self.emptyMessage = ""
                BirdDataService.shared.getObservationsNearby {
                    self.observations = BirdDataService.shared.observations
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }

    
    func tableView(_ tableView: UITableView, didSelectItemAt indexPath: IndexPath) {
        selectedBird = BirdDataService.shared.birds[indexPath.row]
        print(selectedBird?.comName as Any)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDetailFromNearby" {
            if let destVC = segue.destination as? BirdDetailViewController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let observation = self.observations![indexPath.row]
                    selectedBird = BirdDataService.shared.birdsBySpeciesCode[observation.speciesCode]!
                    destVC.bird = selectedBird
                    destVC.showMap = true
                }
            }
        }
    }
}
