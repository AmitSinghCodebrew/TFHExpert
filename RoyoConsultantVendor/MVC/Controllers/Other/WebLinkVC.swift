//
//  WebLinkVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 08/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import WebKit

class WebLinkVC: BaseVC {
    @IBOutlet weak var wkWebView: WKWebView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    public var linkTitle: (url: String?, title: String)?
    
    private var progressObserver: NSKeyValueObservation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = /linkTitle?.title
        wkWebView.load(URLRequest.init(url: URL(string: /linkTitle?.url)!))
        
        progressObserver = wkWebView.observe(\WKWebView.estimatedProgress, options: .new, changeHandler: { [weak self] (wkView, change) in
            let progress = Float(wkView.estimatedProgress)
            self?.progressView.isHidden = progress == 1.0
            self?.progressView.progress = progress
        })
    }
    
    deinit {
        progressObserver = nil
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
}
