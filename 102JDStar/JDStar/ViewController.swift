//
//  ViewController.swift
//  JDStar
//
//  Created by wudong on 2018/11/21.
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
    var shader : BaseEffect!
    
    let vertices : [Vertex] = [
        Vertex( 0.37, -0.12, 0.0),
        Vertex( 0.95,  0.30, 0.0),
        Vertex( 0.23,  0.30, 0.0),
        
        Vertex( 0.23,  0.30, 0.0),
        Vertex( 0.00,  0.90, 0.0),
        Vertex(-0.23,  0.30, 0.0),
        
        Vertex(-0.23,  0.30, 0.0),
        Vertex(-0.95,  0.30, 0.0),
        Vertex(-0.37, -0.12, 0.0),
        
        Vertex(-0.37, -0.12, 0.0),
        Vertex(-0.57, -0.81, 0.0),
        Vertex( 0.00, -0.40, 0.0),
        
        Vertex( 0.00, -0.40, 0.0),
        Vertex( 0.57, -0.81, 0.0),
        Vertex( 0.37, -0.12, 0.0),
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
        
        //shader begin
        self.shader.prepareToDraw()
        //启用顶点属性
        glEnableVertexAttribArray(VertexAttributes.vertexAttribPosition.rawValue)
        //1.指定要修改的顶点属性的索引值；
        //2.每个顶点属性的组件数量；
        //3.指定数组中每个组件的数据类型；
        //4.当被访问时，固定点数据是否应该被归一化（GL_TRUE）或者直接转换为固定值（GL_FALSE）
        //5.指定连续顶点属性之间得偏移量；
        //6.指定第一个组件在数组的第一个顶点属性中的偏移量。该数组与GL_ARRAY_BUFFER绑定，储存于缓冲区中。初始值为0
        glVertexAttribPointer(VertexAttributes.vertexAttribPosition.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), nil)
        //绑定节点缓存
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        //1.绘制三角形；2.从第n个点开始绘制；3.绘制多少个点
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertices.count))
        glDisableVertexAttribArray(VertexAttributes.vertexAttribPosition.rawValue)
    }

}

extension ViewController {
    func setupGLcontext() {
        self.glkView = self.view as! GLKView
        self.glkView.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        EAGLContext.setCurrent(self.glkView.context)
    }
    
    func setupGLupdater() {
        self.glkUpdater = GLKUpdater(glkViewController: self)
        self.delegate = self.glkUpdater
    }
    
    func setupShader() {
        self.shader = BaseEffect(vertexShader: "SimpleVertexShader.glsl", fragmentShader: "SimpleFragmentShader.glsl")
    }
    
    func setupVertexBuffer() {
        //在buffers数组中返回当前n个未使用的名称，表示缓冲区对象
        glGenBuffers(GLsizei(1), &vertexBuffer)
        //指定当前活动缓冲区的对象
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        let count = vertices.count
        let size = MemoryLayout<Vertex>.size
        //用数据分配和初始化缓冲区对象
        glBufferData(GLenum(GL_ARRAY_BUFFER), count*size, vertices, GLenum(GL_STATIC_DRAW))
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer {
        let ptr: UnsafeRawPointer? = nil
        return ptr! + n * MemoryLayout<Void>.size
    }
}
