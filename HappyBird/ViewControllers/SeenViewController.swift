//
//  SeenViewController.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/31/20.
//

import Foundation
import UIKit
import Alamofire

class SeenViewController: UICollectionViewController {
    var selectedBird: Bird?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(seenChanged),
            name: NSNotification.Name(rawValue: "seenChanged"),
            object: nil
        )
    
        BirdDataService.shared.onDataReady {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func seenChanged(notif: NSNotification) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.collectionView.bounds.width, height: 9/16 * self.collectionView.bounds.width)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (BirdDataService.shared.seenBirds.count == 0) {
            collectionView.setEmptyMessage("The birds you mark as seen will appear here.\nGo out bird-watching, and remember to come\nback and mark the birds you have seen.")
        }
        else {
            collectionView.restore()
        }
        return BirdDataService.shared.seenBirds.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seenCell", for: indexPath) as! FavoriteCell
        cell.backgroundImageView.image = nil
        cell.backgroundImageView.isHidden = true
        cell.backgroundImageView.subviews.forEach { $0.removeFromSuperview() }
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.layer.shadowOpacity = 0
        cell.imageView.layer.shadowRadius = 0
        cell.imageView.image = UIImage(named: "PlaceholderImage")
        cell.textLabel.text = nil
//        guard (BirdDataService.shared.families.count > 0) else { return cell }
        let bird = BirdDataService.shared.seenBirds[indexPath.row]
        cell.birdName = bird.comName
        cell.textLabel.text = bird.comName
        DispatchQueue.global(qos: .background).async {
//            guard let birds = family.birds else { return }
            PhotoDataService.shared.getPhotoURL(birds: [bird], size: "z", format: "png") { url in
                guard let url = url, cell.birdName == bird.comName else { return }
                cell.url = url
                cell.request = DataService.shared.request(url) { data, request in
                    cell.request = nil
                    guard let data = data, cell.birdName == bird.comName else { return }
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: data)?.cropMargins()
                        if (cell.imageView.image?.size.width)! < 2.5 / 2 * (cell.imageView.image?.size.height)! {
                            cell.backgroundImageView.image = UIImage(data: data)?.cropMargins()?.alpha(0.75)
                            cell.backgroundImageView.isHidden = false
                            let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
                            let blurView = UIVisualEffectView(effect: blur)
                            blurView.frame = cell.backgroundImageView.bounds
                            cell.backgroundImageView.addSubview(blurView)
                            cell.backgroundImageView.backgroundColor = UIColor.black
                            cell.imageView.contentMode = .scaleAspectFit
                            cell.imageView.layer.shadowColor = UIColor.black.cgColor
                            cell.imageView.layer.shadowOpacity = 1
                            cell.imageView.layer.shadowOffset = .zero
                            cell.imageView.layer.shadowRadius = 50
                        }
                    }
                }
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selectedBird = BirdDataService.shared.seenBirds[indexPath.row]
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDetailFromSeen" {
            if let destVC = segue.destination as? DetailViewController {
                destVC.bird = selectedBird!
            }
        }
    }
}
