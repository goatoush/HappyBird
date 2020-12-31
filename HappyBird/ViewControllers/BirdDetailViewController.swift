//
//  BirdDetailViewController.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/28/20.
//

import Foundation
import UIKit
import Alamofire

class BirdDetailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var favorite: UIBarButtonItem!
    @IBOutlet var contentView: UIView!
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
    var bird: Bird!
    var slides: [Slide] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isFavorited \(self.bird.sciName)") {
            favorite.image = UIImage(systemName: "heart.fill")
        }
        self.stackView.setCustomSpacing(10, after: pageControl)
        self.stackView.setCustomSpacing(17, after: sciName)
        self.stackView.setCustomSpacing(0, after: orderHeader)
        self.stackView.setCustomSpacing(24, after: order)
        self.stackView.setCustomSpacing(0, after: familyHeader)
        self.title = self.bird.comName
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
        view.bringSubviewToFront(pageControl)
        //self.scrollView.contentSize = contentView.frame.size
    }
    
    @IBAction func favoriteBird() {
        if BirdDataService.shared.toggleFavorite(bird: self.bird) {
            favorite.image = UIImage(systemName: "heart.fill")
        }
        else {
            favorite.image = UIImage(systemName: "heart")
        }
//        if UserDefaults.standard.bool(forKey: "isFavorited \(self.bird.sciName)") {
//            favorite.image = UIImage(systemName: "heart")
//            UserDefaults.standard.set(false, forKey: "isFavorited \(self.bird.sciName)")
//            BirdDataService.shared.favoritedBirds = BirdDataService.shared.favoritedBirds.filter { $0 != self.bird }
//        }
//        else {
//            favorite.image = UIImage(systemName: "heart.fill")
//            UserDefaults.standard.set(true, forKey: "isFavorited \(self.bird.sciName)")
//            BirdDataService.shared.favoritedBirds.append(self.bird)
//        }
    }
    
    func getImages(_ maxCount: Int = 5) {
        PhotoDataService.shared.getPhotoURLs(birds: [bird], size: "z") { urlStrings in
            guard urlStrings.count > 0 else {
                DispatchQueue.main.async {
                    let slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                    self.slides.append(slide)
//                    self.pageControl.numberOfPages = self.slides.count
//                    self.pageControl.alpha = self.slides.count < 2 ? 0 : 1
                    slide.imageView.image = UIImage(named: "PlaceholderImage")
                    self.pageScrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.width * 2/3)
                    slide.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                    self.pageScrollView.addSubview(slide)
                }
                return
            }
            self.pageControl.isHidden = urlStrings.count < 2
            self.scrollView.contentSize = self.contentView.frame.size
            for i in 0..<min(urlStrings.count, maxCount) {
                DataService.shared.request(urlStrings[i]) { data, request in
                    guard let data = data else { return }
                    DispatchQueue.main.async {
                        let slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
                        self.slides.append(slide)
                        slide.imageView.image = UIImage(data: data)
                        if (slide.imageView.image?.size.width)! < 2.5 / 2 * (slide.imageView.image?.size.height)! {
                            slide.backgroundImageView.image = UIImage(data: data)?.alpha(0.75)
                            slide.backgroundImageView.isHidden = false
                            let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
                            let blurView = UIVisualEffectView(effect: blur)
                            blurView.frame = slide.backgroundImageView.bounds
                            slide.backgroundImageView.addSubview(blurView)
                            slide.backgroundImageView.backgroundColor = UIColor.black
                            slide.imageView.contentMode = .scaleAspectFit
                            slide.imageView.layer.shadowColor = UIColor.black.cgColor
                            slide.imageView.layer.shadowOpacity = 1
                            slide.imageView.layer.shadowOffset = .zero
                            slide.imageView.layer.shadowRadius = 50
                        }
                        self.pageControl.numberOfPages = self.slides.count
                        self.pageControl.alpha = self.slides.count < 2 ? 0 : 1
                        self.pageScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(self.slides.count), height: self.view.frame.width * 2/3)
                        slide.frame = CGRect(x: self.view.frame.width * CGFloat(i), y: 0, width: self.view.frame.width, height: self.view.frame.height)
                        self.pageScrollView.addSubview(slide)
                        //self.scrollView.contentSize = self.contentView.frame.size
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
