//
//  OpenGLESView.swift
//  JDGLESShader
//
//  Created by wudong on 2018/12/12.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit
import GLKit

class OpenGLESView: UIView {
    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    var colorRenderBuffer: GLuint = 0
    var frameBuffer: GLuint = 0
    var program: GLuint = 0
    
    let vertices: [GLfloat] = [
        0.0,  0.5, 0.0,
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0
    ]
    
    let colors: [GLfloat] = [
        0.0, 1.0, 1.0,
        1.0, 0.0, 1.0,
        1.0, 1.0, 0.0
    ]
    
    override class var layerClass: AnyClass {
        
        return CAEAGLLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayer()
        self.setupContext()
        self.setupGLProgram()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.destoryRenderAndFrameBuffer()
        self.setupFrameAndRenderBuffer()
        self.render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OpenGLESView {
    func setupLayer() {
        self.eaglLayer = self.layer as! CAEAGLLayer
        self.eaglLayer.isOpaque = true
        self.eaglLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking:false,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8]
    }
    
    func setupContext() {
        self.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        EAGLContext.setCurrent(self.context)
    }
    
    func setupGLProgram() {
        let vertFile = Bundle.main.path(forResource: "vert.glsl", ofType: nil)
        let fragFile = Bundle.main.path(forResource: "frag.glsl", ofType: nil)
        guard vertFile != nil else {
            print("vert file load false")
            exit(1)
        }
        
        guard fragFile != nil else {
            print("frag file load false")
            exit(1)
        }
        let vertCstring = (vertFile as! NSString).utf8String
        let framCstring = (fragFile as! NSString).utf8String
        self.program = createGLProgramFromFile(vertCstring, framCstring)
        glUseProgram(self.program)
    }
    
    func setupFrameAndRenderBuffer() {
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.eaglLayer)
        
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    }
    
    func setupVertexData() {
        let posSlot: GLuint = GLuint(glGetAttribLocation(self.program, "position"))
        glVertexAttribPointer(posSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices)
        glEnableVertexAttribArray(posSlot)
        
        let colorSlot: GLuint = GLuint(glGetAttribLocation(self.program, "color"))
        glVertexAttribPointer(colorSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, colors)
        glEnableVertexAttribArray(colorSlot)
    }
    
    func destoryRenderAndFrameBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &colorRenderBuffer)
        colorRenderBuffer = 0
    }
    
    func render() {
        glClearColor(1.0, 1.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glViewport(0, 0, GLsizei(self.frame.width), GLsizei(self.frame.height))
        self.setupVertexData()
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}

