//
//  ViewController.swift
//  JDOpengGLESBase
//
//  Created by wudong on 2018/11/28.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit
import GLKit

class ViewController: GLKViewController {
    
    var mContext: EAGLContext!
    var mEffect: GLKBaseEffect!
    
    let vertexData : [Vertex] = [
        Vertex(0.5, -0.5, 0.0, 1.0, 0.0),
        Vertex(0.5, 0.5, -0.0, 1.0, 1.0),
        Vertex(-0.5, 0.5, 0.0, 0.0, 1.0),
        
        Vertex(0.5, -0.5, 0.0, 1.0, 0.0),
        Vertex(-0.5, 0.5, 0.0, 0.0, 1.0),
        Vertex(-0.5, -0.5, 0.0, 0.0, 0.0),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupConfig()
        self.uploadVertexArray()
        self.uploadTexture()
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.3, 0.6, 1.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        self.mEffect.prepareToDraw()
        glDrawArrays(GLenum(GL_TRIANGLES), GLint(0), GLsizei(vertexData.count))
    }

}

extension ViewController {
    func setupConfig() {
        self.mEffect = GLKBaseEffect()

        self.mContext = EAGLContext.init(api: EAGLRenderingAPI.openGLES2)
        let view = self.view as! GLKView
        view.context = self.mContext
        view.drawableColorFormat = GLKViewDrawableColorFormat.RGBA8888
        EAGLContext.setCurrent(self.mContext)
    }
    
    func uploadVertexArray()  {
       
        
        var buffer: GLuint = 0
        let count = vertexData.count
        let size = MemoryLayout<Vertex>.size

        glGenBuffers(1, &buffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), buffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), count*size, vertexData, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3*MemoryLayout<GLfloat>.size))
        
    }
    
    func uploadTexture() {
        if let filePath = Bundle.main.path(forResource: "999.jpg", ofType: nil) {
            let options = [GLKTextureLoaderOriginBottomLeft:true]
            do {
                let textureInfo = try GLKTextureLoader.texture(withContentsOfFile: filePath, options: options as [String : NSNumber])
                
                self.mEffect.texture2d0.enabled = GLboolean(GL_TRUE)
                self.mEffect.texture2d0.name = textureInfo.name
            }catch {
                exit(1)
            }
            
        }
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
}
