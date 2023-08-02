//
//  MapView Controller.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 1/9/21.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var count: UILabel!
    var titleLabelText: String = ""
    var sightings: [Sighting] = []
    
    override func viewDidLoad() {
        count.text = "Count: \(sightings.count)"
        titleLabel.text = titleLabelText
        mapView.addAnnotations(sightings)
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        titleLabel.layer.shadowRadius = 0.5
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        
        count.layer.shadowOpacity = 1
        count.layer.shadowOffset = CGSize(width: 0, height: 0)
        count.layer.shadowRadius = 0.5
        count.layer.shadowColor = UIColor.black.cgColor
    }
    
    
}
