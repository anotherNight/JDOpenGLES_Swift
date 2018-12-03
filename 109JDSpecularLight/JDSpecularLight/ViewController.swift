//
//  ViewController.swift
//  JDAmbientLight
//
//  Created by wudong on 2018/11/23.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit
import GLKit

class GLKUpdater : NSObject, GLKViewControllerDelegate {
    
    weak var glkViewController : ViewController!
    
    init(glkViewController : ViewController) {
        self.glkViewController = glkViewController
    }
    
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        self.glkViewController.cube.updateWithDelta(self.glkViewController.timeSinceLastUpdate)
    }
}

class ViewController: GLKViewController {
    
    var glkView: GLKView!
    var glkUpdater: GLKUpdater!
    var shader : BaseEffect!
    var cube : Cube!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGLcontext()
        setupGLupdater()
        setupScene()
    }


    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        //Transfomr4: Viewport: Normalized -> Window
        glClearColor(1.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_CULL_FACE))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        let viewMatrix : GLKMatrix4 =  GLKMatrix4Rotate(GLKMatrix4MakeTranslation(0, 0, -5), GLKMathDegreesToRadians(20), 1, 0, 0)
        //self.square.renderWithParentMoelViewMatrix(viewMatrix)
        self.cube.renderWithParentModelViewMatrix(viewMatrix)
    }
    
}

extension ViewController {
    
    func setupGLcontext() {
        glkView = self.view as! GLKView
        glkView.context = EAGLContext(api: .openGLES2)!
        glkView.drawableDepthFormat = .format16         // for depth testing
        EAGLContext.setCurrent(glkView.context)
    }
    
    func setupGLupdater() {
        self.glkUpdater = GLKUpdater(glkViewController: self)
        self.delegate = self.glkUpdater
    }
    
    func setupScene() {
        self.shader = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
        
        self.shader.projectionMatrix = GLKMatrix4MakePerspective(
            GLKMathDegreesToRadians(85.0),
            GLfloat(self.view.bounds.size.width / self.view.bounds.size.height),
            1,
            150)
        
        self.cube = Cube(shader: self.shader)
        
    }
    
    
}
