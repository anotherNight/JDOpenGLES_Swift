//
//  ViewController.swift
//  JDRedAlert
//
//  Created by wudong on 2018/11/28.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit
import GLKit

class ViewController: GLKViewController {

    var glkView:GLKView!
    var glkUpdater: GLKUpdater!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.glkView = self.view as! GLKView
        self.glkView.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        EAGLContext.setCurrent(self.glkView.context)
        
        self.glkUpdater = GLKUpdater(glkViewController: self)
        self.delegate = self.glkUpdater
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(Float(glkUpdater.redValue), 0.0, 0.0, 1.0)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
}


class GLKUpdater: NSObject,GLKViewControllerDelegate {
    var redValue : Double = 0.0
    let durationOfFlash : Double = 2.0
    weak var glkViewController : GLKViewController!
    
    init(glkViewController:GLKViewController) {
        self.glkViewController = glkViewController
    }
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        redValue = (sin(self.glkViewController.timeSinceFirstResume * 2 * Double.pi/durationOfFlash) * 0.5) + 0.5
    }
}
