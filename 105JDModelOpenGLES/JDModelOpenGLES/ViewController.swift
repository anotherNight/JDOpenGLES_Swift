//
//  ViewController.swift
//  JDModelOpenGLES
//
//  Created by wudong on 2018/11/22.
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
//        self.glkViewController.square.updateWithDelta(self.glkViewController.timeSinceLastUpdate)
        self.glkViewController.cube.updateWithDelta(self.glkViewController.timeSinceLastUpdate)
    }
}


class ViewController: GLKViewController {
    var glkView: GLKView!
    var glkUpdater: GLKUpdater!
    var shader : BaseEffect!
    var square : Square!
    var cube: Cube!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGLcontext()
        setupGLupdater()
        setupScene()
        
    }
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(1.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        //
        glEnable(GLenum(GL_DEPTH_TEST))
        //
        glEnable(GLenum(GL_CULL_FACE))
        //
        glEnable(GLenum(GL_BLEND))
        //
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        let viewMatrix: GLKMatrix4 = GLKMatrix4MakeTranslation(0, -1, -5)
//        self.square.render()
//        self.square.renderWithParentModelViewMarix(viewMatrix)
        self.cube.renderWithParentModelViewMarix(viewMatrix)
    }

}

extension ViewController {
    func setupGLcontext() {
        glkView = self.view as! GLKView
        glkView.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        EAGLContext.setCurrent(glkView.context)
    }
    
    func setupGLupdater() {
        self.glkUpdater = GLKUpdater(glkViewController: self)
        self.delegate = self.glkUpdater
    }
    func setupScene()  {
        self.shader = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
        
        //GLKit提供了GLKMatrix4MakePerspective方法便捷的生成透视投影矩阵。
        //方法有4个参数float fovyRadians, float aspect, float nearZ, float farZ。fovyRadians表示视角。aspect表示屏幕宽高比，为了将所有轴的单位长度统一，所以需要知道屏幕宽高比多少。nearZ表示可视范围在Z轴的起点到原点(0,0,0)的距离，farZ表示可视范围在Z轴的终点到原点(0,0,0)的距离,nearZ和farZ始终为正。下面是透视投影的剖面示意图。
        let aspect = self.view.bounds.size.width / self.view.bounds.size.height
        self.shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), GLfloat(aspect), 1, 150)
//        self.square = Square(shader: self.shader)
//        self.square.position = GLKVector3(v: (0.5, -0.5, 0))
        self.cube = Cube(shader:self.shader)
    }
}
