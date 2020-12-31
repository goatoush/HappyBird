//
//  BirdsViewController.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/20/20.
//

import Foundation
import UIKit
import Alamofire

class FamilyCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textLabelContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var url: String?
    var familyName: String?
    var request: Alamofire.Request?

    override func prepareForReuse() {
        super.prepareForReuse()
        request?.cancel()
        request = nil
        textLabel.text = nil
        imageView.image = nil
        url = nil
        familyName = nil
    }
}

class BirdsViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    var selectedFamily: Family? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BirdDataService.shared.onDataReady {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: self.collectionView.bounds.width/2, height: self.collectionView.bounds.width/2)
        }
    }
}

extension BirdsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BirdDataService.shared.families.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FamilyCell", for: indexPath) as! FamilyCell
        cell.imageView.image = nil
        cell.textLabel.text = nil
        guard (BirdDataService.shared.families.count > 0) else { return cell }
        let family = BirdDataService.shared.families[indexPath.row]
        cell.familyName = family.groupName
        cell.textLabel.text = family.groupName
        DispatchQueue.global(qos: .background).async {
            guard let birds = family.birds else { return }
            PhotoDataService.shared.getPhotoURL(birds: birds, size: "z", format: "png") { url in
                guard let url = url, cell.familyName == family.groupName else { return }
                cell.url = url
                cell.request = DataService.shared.request(url) { data, request in
                    cell.request = nil
                    guard let data = data, cell.familyName == family.groupName else { return }
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: data)?.cropMargins()
                    }
                }
            }
        }
        return cell
    }
}

extension BirdsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selectedFamily = BirdDataService.shared.families[indexPath.row]
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FamilyCell
        if let url = cell.url { print("\t\t\"\(url.replacingOccurrences(of: "_z", with: ""))\",") }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewFamily" {
            if let destVC = segue.destination as? BirdsTableViewController {
                destVC.family = selectedFamily!
            }
        }
    }
}
