//
//  ViewController.swift
//  JDMasking
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
        self.glkViewController.frame.updateWithDelta(self.glkViewController.timeSinceLastUpdate)
    }
}

class ViewController: GLKViewController {

    var glkView: GLKView!
    var glkUpdater: GLKUpdater!
    var shader : BaseEffect!
    var zombie : MaskedSquare!
    var frame : MaskedSquare!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGLcontext()
        setupGLupdater()
        setupScene()
    }

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(1.0, 0.0, 0.0, 1.0);
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        glEnable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_CULL_FACE))
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        let viewMatrix : GLKMatrix4 = GLKMatrix4MakeTranslation(0, 0, -5)
        self.zombie.renderWithParentModelViewMatrix(viewMatrix)
        self.frame.renderWithParentModelViewMatrix(viewMatrix)
    }
    

}

extension ViewController {
    
    func setupGLcontext() {
        glkView = self.view as! GLKView
        glkView.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        //    你的OpenGL上下文还可以（可选地）有另一个缓冲区，称为深度缓冲区。这帮助我们确保更接近观察者的对象显示在远一些的对象的前面（意思就是离观察者近一些的对象会挡住在它后面的对象）。
        
        //    其缺省的工作方式是：OpenGL把接近观察者的对象的所有像素存储到深度缓冲区，当开始绘制一个像素时，它（OpenGL）首先检查深度缓冲区，看是否已经绘制了更接近观察者的什么东西，如果是则忽略它（要绘制的像素，就是说，在绘制一个像素之前，看看前面有没有挡着它的东西，如果有那就不用绘制了）。否则，把它增加到深度缓冲区和颜色缓冲区。
        
        //    你可以设置这个属性，以选择深度缓冲区的格式。缺省值是GLKViewDrawableDepthFormatNone，意味着完全没有深度缓冲区。
        
        //    但是如果你要使用这个属性（一般用于3D游戏），你应该选择GLKViewDrawableDepthFormat16或GLKViewDrawableDepthFormat24。这里的差别是使用GLKViewDrawableDepthFormat16将消耗更少的资源，但是当对象非常接近彼此时，你可能存在渲染问题（）
        glkView.drawableDepthFormat = .format16
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
        self.zombie = MaskedSquare(shader: self.shader, texture: "picture.png", mask: "picture-frame-mask.png")
        self.frame = MaskedSquare(shader: self.shader, texture: "picture-frame.png", mask: nil)
        self.frame.position = GLKVector3Make(0, 0, 0.1)
    }

}
