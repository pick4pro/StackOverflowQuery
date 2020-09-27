//
//  WebViewController.swift
//  TestJSON
//
//  Created by Jimmy Wright on 9/26/20.
//  Copyright © 2020 Jimmy Wright. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var urlString: String?
    var webView: WKWebView!
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // Uncomment out below line to check for retain cycles.  If print does not occur in console then need to investigate further why view controller was not de-allocated.
        // print("WebViewController deinit called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
    }
    
    private func setupWebView() {
        if let urlString = urlString {
            webView = WKWebView()
            view = webView
            let url = URL(string: urlString)!
            webView.load(URLRequest(url: url))
        }
    }
}
