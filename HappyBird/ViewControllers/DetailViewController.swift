//
//  DetailViewController.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/28/20.
//

import Foundation
import UIKit
import Alamofire
import MapKit

class Sighting: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}

class DetailViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var favorite: UIBarButtonItem!
    @IBOutlet var seen: UIBarButtonItem!
//    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageScrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var comName: UILabel!
    @IBOutlet var sciName: UILabel!
    @IBOutlet var orderHeader: UILabel!
    @IBOutlet var order: UILabel!
    @IBOutlet var familyHeader: UILabel!
    @IBOutlet var familyCom: UILabel!
    @IBOutlet var familySci: UILabel!
    @IBOutlet var findInBrowse: UIButton!
    @IBOutlet var mapContainer: UIView!
    @IBOutlet var mapView: MKMapView!
    var showMap = false
    var sightings: [Sighting] = []
    var bird: Bird!
    var slides: [Slide] = []
    var showFindInBrowse = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isFavorited \(self.bird.sciName)") {
            favorite.image = UIImage(systemName: "heart.fill")
        }
        if UserDefaults.standard.bool(forKey: "hasSeen \(self.bird.sciName)") {
            seen.image = UIImage(systemName: "binoculars.fill")
        }
        self.stackView.setCustomSpacing(16, after: sciName)
        self.stackView.setCustomSpacing(16, after: order)
        self.stackView.setCustomSpacing(16, after: familySci)
        self.title = ""
        self.comName.text = self.bird.comName
        if self.bird.extinct ?? false {
            self.comName.text = self.comName.text! + " (extinct)"
            self.comName.textColor = UIColor.red
        }
        self.sciName.text = self.bird.sciName
        self.order.text = self.bird.order
        self.familyCom.text = self.bird.familyComName
        self.familySci.text = self.bird.familySciName
        pageScrollView.delegate = self
        getImages(20)
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        pageControl.alpha = 0
        view.bringSubviewToFront(pageControl)
        if !showMap {
            mapContainer.isHidden = true
        }
        if !showFindInBrowse {
            findInBrowse.isHidden = true
        }
        else {
            BirdDataService.shared.getObservationsBySpeciesCode(bird.speciesCode) { [self] (observations) in
                for sighting in observations {
                    //print(sighting.lat, sighting.lng)
                    if sighting.speciesCode == bird.speciesCode {

                        sightings.append(Sighting(title: "", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(sighting.lat), longitude: CLLocationDegrees(sighting.lng)), info: sighting.locName))
                        mapView.addAnnotations(sightings)
                     }
                }
                mapView.showAnnotations(mapView.annotations, animated: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     }
    
    @IBAction func favoriteBird() {
        if BirdDataService.shared.toggleFavorite(bird: self.bird) {
            favorite.image = UIImage(systemName: "heart.fill")
        }
        else {
            favorite.image = UIImage(systemName: "heart")
        }
    }
    
    @IBAction func birdSighted(_ sender: Any) {
        if BirdDataService.shared.toggleSeen(bird: self.bird) {
            seen.image = UIImage(systemName: "binoculars.fill"/*, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)*/)
        }
        else {
            seen.image = UIImage(systemName: "binoculars"/*, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)*/)
        }
    }
    
    func getImages(_ maxCount: Int = 5) {
        PhotoDataService.shared.getPhotoURLs(birds: [bird], size: "z") { urlStrings, titles  in
            guard urlStrings.count > 0 else {
                DispatchQueue.main.async {
                    let slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                    self.slides.append(slide)
                    slide.imageView.image = UIImage(named: "PlaceholderImage")
                    slide.flickrIcon.isHidden = true
                    slide.textLabel.isHidden = true
                    self.pageScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.width * 2/3)
                    slide.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.pageScrollView.addSubview(slide)
                }
                return
            }
            self.pageControl.isHidden = urlStrings.count < 2
//          self.scrollView.contentSize = self.contentView.frame.size
            for i in 0..<min(urlStrings.count, maxCount) {
                DataService.shared.request(urlStrings[i]) { data, request in
                    guard let data = data else { return }
                    DispatchQueue.main.async {
                        let slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                        self.slides.append(slide)
                        slide.imageView.image = UIImage(data: data)
                        slide.textLabel.text = titles[i]
                        if (slide.imageView.image?.size.width)! < 2.5 / 2 * (slide.imageView.image?.size.height)! {
                            slide.backgroundImageView.image = UIImage(data: data)?.alpha(0.75)
                            slide.backgroundImageView.isHidden = false
                            let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
                            let blurView = UIVisualEffectView(effect: blur)
                            slide.backgroundImageView.addSubview(blurView)
//                            blurView.frame = slide.backgroundImageView.bounds
                            blurView.translatesAutoresizingMaskIntoConstraints = false
                            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[blur]-0-|", metrics: nil, views: ["blur": blurView])
                            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[blur]-0-|", metrics: nil, views: ["blur": blurView])
                            NSLayoutConstraint.activate(horizontalConstraints)
                            NSLayoutConstraint.activate(verticalConstraints)
                            slide.backgroundImageView.backgroundColor = UIColor.black
                            slide.imageView.contentMode = .scaleAspectFit
                            slide.imageView.layer.shadowColor = UIColor.black.cgColor
                            slide.imageView.layer.shadowOpacity = 1
                            slide.imageView.layer.shadowOffset = .zero
                            slide.imageView.layer.shadowRadius = 50
                        }
                        self.pageControl.numberOfPages = self.slides.count
                        self.pageControl.isUserInteractionEnabled = self.slides.count >= 2
                        self.pageControl.alpha = self.slides.count < 2 ? 0 : 1
                        self.pageScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(self.slides.count), height: self.view.frame.width * 2/3)
                        slide.frame = CGRect(x: self.view.frame.width * CGFloat(i), y: 0, width: self.view.frame.width, height: self.view.frame.height)
                        self.pageScrollView.addSubview(slide)
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewMap" {
            print("Identifier is viewMap")
            if let destVC = segue.destination as? MapViewController {
                destVC.sightings = self.sightings
                destVC.titleLabelText = "Nearby Sightings of " + self.bird.comName
                print("destVC is MapViewController")
            }
        }
        else if segue.identifier == "findInBrowse" {
            if let destVC = segue.destination as? BirdsTableViewController {
                destVC.family = BirdDataService.shared.families[bird.speciesGroupIndex ?? 0]
                destVC.highlightedBird = bird
            }
        }
    }
}
