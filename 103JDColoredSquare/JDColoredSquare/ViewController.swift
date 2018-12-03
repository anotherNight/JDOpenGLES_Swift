//
//  ViewController.swift
//  JDColoredSquare
//
//  Created by wudong on 2018/11/22.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit
import GLKit

class GLKUpdater : NSObject, GLKViewControllerDelegate {
    
    weak var glkViewController : GLKViewController!
    
    init(glkViewController : GLKViewController) {
        self.glkViewController = glkViewController
    }
    
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
    }
}

class ViewController: GLKViewController {

    var glkView: GLKView!
    var glkUpdater: GLKUpdater!
    
    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    var shader: BaseEffect!
    
    let vertices:[Vertex] = [
        Vertex( 1.0, -1.0, 0, 1.0, 0.0, 0.0, 1.0),
        Vertex( 1.0,  1.0, 0, 0.0, 1.0, 0.0, 1.0),
        Vertex(-1.0,  1.0, 0, 0.0, 0.0, 1.0, 1.0),
        Vertex(-1.0, -1.0, 0, 1.0, 1.0, 0.0, 1.0)
    ]
    
    let indices: [GLubyte] = [
        0,1,2,
        2,3,0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGLcontext()
        setupGLupdater()
        setupShader()
        setupVertexBuffer()
        
    }

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.0, 1.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        shader.prepareToDraw()
        
        glEnableVertexAttribArray(VertexAttributes.position.rawValue)
        glVertexAttribPointer(VertexAttributes.position.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        
        glEnableVertexAttribArray(VertexAttributes.color.rawValue)
        glVertexAttribPointer(VertexAttributes.color.rawValue, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3*MemoryLayout<GLfloat>.size))
        // x, y, z | r, g, b, a :: offset is 3*sizeof(GLfloat)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glDisableVertexAttribArray(VertexAttributes.position.rawValue)
    }
}


extension ViewController {
    func setupGLcontext() {
        glkView = self.view as! GLKView
        if let context = EAGLContext(api: EAGLRenderingAPI.openGLES2) {
            glkView.context = context
            EAGLContext.setCurrent(glkView.context)
        }
    }
    
    func setupGLupdater() {
        self.glkUpdater = GLKUpdater(glkViewController: self)
        self.delegate = self.glkUpdater
    }
    
    func setupShader() {
        self.shader = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
    }
    
    func setupVertexBuffer() {
        glGenBuffers(GLsizei(1), &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        let count = vertices.count
        let size = MemoryLayout<Vertex>.size
        glBufferData(GLenum(GL_ARRAY_BUFFER), count*size, vertices, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(GLsizei(1), &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count*MemoryLayout<Vertex>.size, indices, GLenum(GL_STATIC_DRAW))
        
        
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
}
