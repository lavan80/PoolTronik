//
//  AboutViewController.swift
//  PoolTronik
//
//  Created by Alexey Kozlov on 06/03/2019.
//  Copyright © 2019 Alexey Kozlov. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        let url = URL(string: "http://www.jenyazla.wixsite.com/pool-tronic")
        webView.load(URLRequest(url: url!))
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
