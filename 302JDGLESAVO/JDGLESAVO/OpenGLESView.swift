//
//  OpenGLESView.swift
//  JDGLESAVO
//
//  Created by wudong on 2018/12/14.
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
    var vertCount: Int = 0
    
    var vertices: [Vertex] = []
    var vao: GLuint = 0

    override class var layerClass: AnyClass {
        
        return CAEAGLLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayer()
        self.setupContext()
        self.setupGLProgram()
        self.setupVertexData()
        self.setupVAO()
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
        self.context = EAGLContext(api: EAGLRenderingAPI.openGLES3)!
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
        
        let vertPathCstring = (vertFile as! NSString).utf8String
        let fragPathCstring = (fragFile as! NSString).utf8String
        self.program = createGLProgramFromFile(vertPathCstring, fragPathCstring)
//        self.program = createGLProgram(vertCstring, fragCstring)
        glUseProgram(self.program)
    }
    
    func setupVertexData() {
        
        let p1 = CGPoint(x: -0.8, y: 0)
        let p2 = CGPoint(x: 0.8, y: 0.2)
        
        let control = CGPoint(x: 0, y: -0.9)
        let deltaT: CGFloat = 0.01
        
        vertCount = Int(1.0/deltaT);
        var i: Int = 0
        while i < vertCount {
            let t: CGFloat = CGFloat(i) * deltaT
            let cx: CGFloat = (1-t)*(1-t)*p1.x + 2*t*(1-t)*control.x + t*t*p2.x
            let cy: CGFloat = (1-t)*(1-t)*p1.y + 2*t*(1-t)*control.y + t*t*p2.y
            vertices.append(Vertex(GLfloat(cx), GLfloat(cy), 0.0, 1.0, 0.0, 0.0))
            print("%f, %f\n",cx, cy);
            i = i+1
        }
        
//        let posSlot: GLuint = GLuint(glGetAttribLocation(self.program, "position"))
//        glVertexAttribPointer(posSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices)
//        glEnableVertexAttribArray(posSlot)
//
//        let colorSlot: GLuint = GLuint(glGetAttribLocation(self.program, "color"))
//        glVertexAttribPointer(colorSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, colors)
//        glEnableVertexAttribArray(colorSlot)
    }
    
    func destoryRenderAndFrameBuffer() {
        glDeleteFramebuffers(1, &frameBuffer)
        frameBuffer = 0
        glDeleteRenderbuffers(1, &colorRenderBuffer)
        colorRenderBuffer = 0
    }
    
    func setupVAO() {
        glGenVertexArrays(1, &vao)
        glBindVertexArray(vao)
        
        let vbo = createVBO(GLenum(GL_ARRAY_BUFFER), GL_STATIC_DRAW, Int32(MemoryLayout<Vertex>.size * (vertCount+1)), &vertices)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        
        glEnableVertexAttribArray(1)
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3*MemoryLayout<GLfloat>.size))
        
        glBindVertexArray(0)
        
    }
    
    func setupFrameAndRenderBuffer() {
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.eaglLayer)
        
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    }
    
    func render() {
        glClearColor(1.0, 1.0, 0.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glLineWidth(2.0)
        
        glViewport(0, 0, GLsizei(self.frame.width), GLsizei(self.frame.height))
        
        
        glBindVertexArray(vao)
        
        glDrawArrays(GLenum(GL_LINE_STRIP), 0, GLsizei(vertCount))
        
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
}

