//
//  ViewController.swift
//  JDGLESShader
//
//  Created by wudong on 2018/12/12.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = OpenGLESView.init(frame: self.view.bounds)
    }


}

