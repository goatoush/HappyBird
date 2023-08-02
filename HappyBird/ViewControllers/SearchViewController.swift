//
//  SearchViewController.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/29/20.
//

import Foundation
import UIKit
import Alamofire

class SearchCell: UITableViewCell {
    @IBOutlet var birdPhoto: UIImageView!
    @IBOutlet var birdName: UILabel!
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

class SearchViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    var families: [Family] = []
    var results: [Family] = []
    var searchString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        searchBar.delegate = self
        DispatchQueue.global(qos: .background).async {
            BirdDataService.shared.onDataReady { [self] in
                families = BirdDataService.shared.families
                families.sort { (lhs, rhs) -> Bool in lhs.groupName < rhs.groupName }
                results = families
                DispatchQueue.main.async {
                    print("reload search", self.results.count)
                    tableView.reloadData()
                }
            }
        }
    }
       
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.results.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results[section].birds?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.results[section].groupName
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> SearchCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell
        let bird = self.results[indexPath.section].birds![indexPath.row]
        cell.birdName.setHighlighted(bird.comName, with: searchString)
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[label]-10-|", metrics: nil, views: ["label": label, "view": view]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[label]-0-|", metrics: nil, views: ["label": label, "view": view]))
        let text = self.tableView(tableView, titleForHeaderInSection: section)!
        label.setHighlighted(text, with: searchString)
        return view
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchString = ""
        results = families
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        searchString = searchText
        if searchText == "" {
            results = families
        }
        else {
            results = families
            for i in 0..<results.count {
                results[i].birds = []
                for bird in families[i].birds ?? [] {
                    if bird.comName.localizedCaseInsensitiveContains(searchText) || bird.sciName.localizedCaseInsensitiveContains(searchText) || bird.speciesCode.localizedCaseInsensitiveContains(searchText) || bird.familyComName!.localizedCaseInsensitiveContains(searchText) ||    bird.familySciName!.localizedCaseInsensitiveContains(searchText) || ("extinct".localizedCaseInsensitiveContains(searchText) && bird.extinct ?? false == true) || bird.order!.localizedCaseInsensitiveContains(searchText) {
                        results[i].birds?.append(bird)
                    }
                }
                if results[i].groupName.localizedCaseInsensitiveContains(searchText) {
                    results[i].birds = families[i].birds
                }
            }
            results = results.filter { $0.birds?.count != 0 }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDetailFromSearch" {
            if let destVC = segue.destination as? DetailViewController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let birds = results[indexPath.section].birds ?? []
                    destVC.bird = birds[indexPath.row]
                }
            }
        }
    }
}
