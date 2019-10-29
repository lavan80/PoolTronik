//
//  MenuViewController.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 06/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation
import UIKit
import SideMenuSwift

enum ViewControllerType: Int {
    case settings = 0
    case about = 1
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var selectionMenuTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuController.preferences.basic.position = .under
        SideMenuController.preferences.basic.menuWidth = 240
        tableView.tableFooterView = UIView()
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = indexPath.row
        if row == ViewControllerType.settings.rawValue {
            cell.textLabel?.text = "Settings"
        } else if row == ViewControllerType.about.rawValue {
            cell.textLabel?.text = "About"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if row == ViewControllerType.settings.rawValue {
            let settingsViewController = storyBoard.instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController
            let navigationController = UINavigationController(rootViewController: settingsViewController)
            navigationController.modalPresentationStyle = .fullScreen
            sideMenuController?.present(navigationController, animated: true, completion: nil)
        } else if row == ViewControllerType.about.rawValue {
            let aboutViewController = storyBoard.instantiateViewController(withIdentifier: "aboutViewController") as! AboutViewController
            let navigationController = UINavigationController(rootViewController: aboutViewController)
            navigationController.modalPresentationStyle = .fullScreen
            sideMenuController?.present(navigationController, animated: true, completion: nil)
        }
        
        
        sideMenuController?.hideMenu()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

