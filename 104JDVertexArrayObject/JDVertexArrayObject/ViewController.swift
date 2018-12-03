//
//  ViewController.swift
//  JDVertexArrayObject
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
    
    var vertexBuffer : GLuint = 0
    var indexBuffer: GLuint = 0
    
    var vao : GLuint = 0            // Vertex Array Object
    var shader : BaseEffect!

    let vertices : [Vertex] = [
        Vertex( 1.0, -1.0, 0, 1.0, 0.0, 0.0, 1.0),
        Vertex( 1.0,  1.0, 0, 0.0, 1.0, 0.0, 1.0),
        Vertex(-1.0,  1.0, 0, 0.0, 0.0, 1.0, 1.0),
        Vertex(-1.0, -1.0, 0, 1.0, 1.0, 0.0, 1.0)
    ]
    
    let indices : [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGLcontext()
        setupGLupdater()
        setupShader()
        setupVertexBuffer()
    }
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(1.0, 0.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        shader.prepareToDraw()
        
        glBindVertexArrayOES(vao)
        //1.mode: 指定绘制图元的类型，GL_POINTS, GL_LINE_STRIP, GL_LINE_LOOP, GL_LINES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_TRIANGLES, GL_QUAD_STRIP, GL_QUADS, and GL_POLYGON
        //2.count：mode类型链接的顶点总数
        //3.type：索引d值的类型，GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, or GL_UNSIGNED_INT
        //4.indices：只想索引存储位置的指针
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }

}

extension ViewController {
    func setupGLcontext() {
        glkView = self.view as! GLKView
        glkView.context = EAGLContext(api: .openGLES2)!
        EAGLContext.setCurrent(glkView.context)
    }
    
    func setupGLupdater() {
        self.glkUpdater = GLKUpdater(glkViewController: self)
        self.delegate = self.glkUpdater
    }
    
    func setupShader() {
        self.shader = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
    }
    
    func setupVertexBuffer() {
        glGenVertexArrays(GLsizei(1), &vao)
        glBindVertexArray(vao)
        
        glGenBuffers(GLsizei(1), &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        let count = vertices.count
        let size = MemoryLayout<Vertex>.size
        glBufferData(GLenum(GL_ARRAY_BUFFER), count*size, vertices, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(GLsizei(1), &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLubyte>.size, indices, GLenum(GL_STATIC_DRAW))
        
        //目前vao是绑定的，所以如果你执行下面的函数，顶点和索引数据都存储在vao中。
        glEnableVertexAttribArray(VertexAttributes.position.rawValue)
        glVertexAttribPointer(VertexAttributes.position.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        
        glEnableVertexAttribArray(VertexAttributes.color.rawValue)
        glVertexAttribPointer(VertexAttributes.color.rawValue, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3*MemoryLayout<GLfloat>.size))
        
        //绑定
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }
    
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
}

