//
//  BirdsTableViewController.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/27/20.
//

import Foundation
import UIKit
import Alamofire

class BirdCell: UITableViewCell {
    @IBOutlet var birdName: UILabel!
    @IBOutlet var birdPhoto: UIImageView!
    var name: String!
    var url: String?
    var request: Alamofire.Request?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        request?.cancel()
        request = nil
        birdName.text = nil
        birdPhoto.image = UIImage(named: "PlaceholderImage")
        url = nil
        name = nil
    }
}

class BirdsTableViewController: UITableViewController {
    var family: Family!
    var selectedBird: Bird? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.title = self.family.groupName
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return family.birds?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> BirdCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BirdCell", for: indexPath) as! BirdCell
        guard let birds = family.birds else { return cell }
        let bird = birds[indexPath.row]
        cell.birdName.text = bird.comName
        cell.name = bird.comName
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
    
    func tableView(_ tableView: UITableView, didSelectItemAt indexPath: IndexPath) {
        selectedBird = BirdDataService.shared.birds[indexPath.row]
        print(selectedBird?.comName as Any)
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDetail" {
            if let destVC = segue.destination as? BirdDetailViewController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    selectedBird = family.birds![indexPath.row]
                    destVC.bird = selectedBird
                }
            }
        }
    }
}
