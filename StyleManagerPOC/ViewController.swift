//
//  ViewController.swift
//  StyleManagerPOC
//
//  Created by Sankar Narayanan on 23/12/15.
//  Copyright © 2015 Sankar Narayanan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        StyleManager.sharedInstance.applyStylesForContainer(StyleManager.containers.sampleViewController, currentViewController: self)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

