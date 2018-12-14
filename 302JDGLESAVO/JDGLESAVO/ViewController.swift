//
//  ViewController.swift
//  JDGLESAVO
//
//  Created by wudong on 2018/12/14.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = OpenGLESView(frame: self.view.frame);
    }


}

