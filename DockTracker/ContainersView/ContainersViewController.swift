//
//  ContainersViewController.swift
//  DockTracker
//
//  Created by Андрей Бабков on 29/10/2018.
//  Copyright © 2018 Андрей Бабков. All rights reserved.
//

import UIKit

class ContainersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containersTable: UITableView!
    
    var containers = [Container]()
    var selectedContainer = Container()
    var groupedContainers = [String: [Container]]()
    var idArray = [String]()
    var containerNum = 0
    var reloadButtonIsBlocked = false
    let cellIdentifier = "containerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserSettings.saveUrl(domain: "andrey-babkov.ru", port: 5555)
        tableView.dataSource = self
        tableView.delegate = self
        getContainers(callback: updateTable)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedContainers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = idArray[indexPath.row]
        let groupOfContainers = groupedContainers[id]
        let amount = groupOfContainers?.count
        let imageName = groupOfContainers?.first?.image ?? "No name"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let castedCell = cell as? ContainerTableCell {
            castedCell.fillCell(with: (imageName, amount!))
        }
        return cell
    }
    
    func getContainers(callback: (() -> Void)? = nil) {
        guard let savedUrl = UserSettings.url else { return }
        let urlString = savedUrl + "/containers/json?all=1"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                self.parseContainers(from: json)
                DispatchQueue.main.async {
                    if (callback != nil) {
                        callback!()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            }.resume()
    }
    
    func parseContainers(from json: Any) {
        guard let postsArray = json as? NSArray else {
            print("Parse error")
            return
        }
        var tmp = [Container]()
        
        for i in postsArray {
            guard let postDict = i as? NSDictionary,
                let container = Container(dict: postDict) else { continue }
            tmp.append(container)
            
            if groupedContainers[container.imageId] != nil {
                groupedContainers[container.imageId]?.append(container)
            } else {
                groupedContainers[container.imageId] = [container]
                idArray.append(container.imageId)
            }
        }
        self.containers = tmp
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedContainer = containers[indexPath.row]
        self.containerNum = indexPath.row
        performSegue(withIdentifier: "openContainer", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openContainer" {
            let container = segue.destination as! ContainerViewController
            container.container = selectedContainer
            container.changeContainersControllerState = changeContainerState
        }
    }
    
    func changeContainerState(_ newState: String) -> Void {
        containers[containerNum].state = newState
        let indexPath = IndexPath(item: containerNum, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBAction func pressReloadButton(_ sender: UIBarButtonItem) {
        if reloadButtonIsBlocked { return }
        blockReloadButton()
        clearData()
        getContainers(callback: {() -> Void in
            self.blockReloadButton()
            self.updateTable()
        })
    }
    
    func clearData() {
        containers.removeAll()
        groupedContainers.removeAll()
        selectedContainer = Container()
        containerNum = 0
    }
    
    func blockReloadButton() {
        reloadButtonIsBlocked = !reloadButtonIsBlocked
    }
    
    func updateTable() {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }
}
