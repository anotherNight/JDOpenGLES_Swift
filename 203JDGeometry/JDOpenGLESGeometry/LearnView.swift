//
//  LearnView.swift
//  JDOpenGLESGeometry
//
//  Created by wudong on 2018/12/3.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit
import GLKit

class LearnView: UIView {
    
    var myContext: EAGLContext!
    var myEagLayer: CAEAGLLayer!
    var myProgram: GLuint = 0
    var myVertices: GLuint = 0
    var indexBuffer: GLuint = 0

    var myColorRenderBuffer: GLuint = 0
    var myColorFrameBuffer: GLuint = 0

    var degree: Float = 0.0
    var yDegree: Float = 0.0
    var bX: Bool = false
    var bY: Bool = false
    var myTimer: Timer?

    let attrArr: [Vertex] = [
        Vertex(-0.5, 0.5, 0.0, 1.0, 0.0, 1.0),
        Vertex(0.5, 0.5, 0.0, 1.0, 0.0, 1.0),
        Vertex(-0.5, -0.5, 0.0, 1.0, 1.0, 1.0),
        Vertex(0.5, -0.5, 0.0, 1.0, 1.0, 1.0),
        Vertex(0.0, 0.0, 1.0, 0.0, 1.0, 0.0),
    ]
    
    let indices: [GLuint] = [
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    ]
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    @IBAction func onXTimer(_ sender: Any) {
        if self.myTimer == nil {
            self.myTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        }
        bX = !bX
    }
    
    
    @IBAction func onYTimer(_ sender: Any) {
        if self.myTimer == nil {
            self.myTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        }
        bY = !bY
    }
    
    @objc func onTimer() {
        degree += bX ? 5 : 0
        yDegree += bY ? 5 : 0
        self.render()
    }
    
    override func layoutSubviews() {
        self.setupLayer()
        self.setupContext()
        self.destoryRenderAndFrameBuffer()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.render()
    }
    
}


extension LearnView {
    
    func setupLayer() {
        self.myEagLayer = (self.layer as! CAEAGLLayer)
        self.contentScaleFactor = UIScreen.main.scale
        self.myEagLayer.isOpaque = true
        self.myEagLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking:true,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8]
    }
    
    func setupContext() {
        if let context = EAGLContext(api: EAGLRenderingAPI.openGLES2) {
            self.myContext = context
        }else {
            print("failed to initialize OpenGLES 2.0 context")
            exit(1)
        }
    }
    
    func destoryRenderAndFrameBuffer() {
        glDeleteFramebuffers(1, &myColorFrameBuffer)
        self.myColorFrameBuffer = 0
        glDeleteFramebuffers(1, &myColorRenderBuffer)
        self.myColorRenderBuffer = 0
    }
    
    func setupRenderBuffer() {
        glGenRenderbuffers(GLsizei(1), &myColorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
        self.myContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.myEagLayer)
    }
    
    func setupFrameBuffer() {
        glGenFramebuffers(GLsizei(1), &myColorFrameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), myColorFrameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
    }
    
    func render() {
        glClearColor(0, 0, 0, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let scale = UIScreen.main.scale
        glViewport(GLint(self.frame.minX * scale), GLint(self.frame.minY * scale), GLsizei(self.frame.width * scale), GLsizei(self.frame.height * scale))
    
        
        if self.myProgram != 0 {
            glDeleteProgram(self.myProgram)
            self.myProgram = 0
        }
        self.myProgram = self.load(verShader: "shaderv.glsl", fragShader: "shaderf.glsl")
        var linkStatus: GLint = 0
        glGetProgramiv(self.myProgram, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            self.validate(programId: self.myProgram)
        }
        glUseProgram(self.myProgram)
        
        
        if self.myVertices == 0 {
            glGenBuffers(GLsizei(1), &myVertices)
        }
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertices)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout.size(ofValue: self.attrArr), self.attrArr, GLenum(GL_DYNAMIC_DRAW))

        glGenBuffers(GLsizei(1), &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLubyte>.size, indices, GLenum(GL_DYNAMIC_DRAW))

        
        //MARK: ???
//        glBindBuffer(GLenum(GL_ARRAY_BUFFER), myVertices)
        let position: GLuint = GLuint(glGetAttribLocation(self.myProgram, "position"))
        glVertexAttribPointer(position, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        glEnableVertexAttribArray(position)
        
        let positionColor: GLuint = GLuint(glGetAttribLocation(self.myProgram, "positionColor"))
        glVertexAttribPointer(positionColor, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(MemoryLayout<GLfloat>.size*3))
        glEnableVertexAttribArray(positionColor)
        
        //matrix
//        var projectionMatrixSlot = glGetUniformLocation(self.myProgram, "projectionMatrix")
//        var modelViewMatrixSlot: GLuint = GLuint(glGetUniformLocation(self.myProgram, "modelViewMatrix"))
//
//        let width: CGFloat = self.frame.width
//        let height: CGFloat = self.frame.height
//
//        var projectionMatrix: KSMatrix4 = KSMatrix4()
//        ksMatrixLoadIdentity(&projectionMatrix)
//        let aspect = width / height
//
//        ksPerspective(&projectionMatrix, 30.0, Float(aspect), 5.0, 20.0)
//
//        glUniformMatrix4fv(projectionMatrixSlot, GLsizei(1), GLboolean(GL_FALSE), UnsafeRawPointer(projectionMatrix.m[0][0]))
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), indices)
        self.myContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func validate(programId: GLuint) -> Bool {
        var logLen: GLint = 0
        var status: GLint = 0
        glValidateProgram(programId)
        glGetProgramiv(programId, GLenum(GL_INFO_LOG_LENGTH), &logLen)
        if logLen > 0 {
            var log: [GLchar] = Array(repeating: GLchar(0), count: Int(logLen))
            glGetProgramInfoLog(programId, logLen, &logLen, UnsafeMutablePointer(mutating: log))
            print("program validate log: \(log)")
        }
        
        glGetProgramiv(programId, GLenum(GL_VALIDATE_STATUS), &status)
        if status == GL_FALSE {
            return false
        }
        return true
    }
    
    func load(verShader: String, fragShader: String) -> GLuint {
        var vShader: GLuint = self.compile(type: GLenum(GL_VERTEX_SHADER), file:verShader)
        var fShader: GLuint = self.compile(type: GLenum(GL_FRAGMENT_SHADER), file:fragShader)
        var program: GLuint = glCreateProgram()
        glAttachShader(program, vShader)
        glAttachShader(program, fShader)
        
        glDeleteShader(vShader)
        glDeleteShader(fShader)
        return program
        
    }
    
    func compile(type: GLenum, file: String) -> GLuint {
        let path = Bundle.main.path(forResource: file, ofType: nil)
        if path == nil {
            print("no file at path: \(path)")
            exit(1)
        }
        do {
            let content: NSString = try NSString.init(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            var shaderCString = content.utf8String
            var shaderStringLen: GLint = GLint(content.length)
            let shader = glCreateShader(type)
            glShaderSource(shader, GLsizei(1), &shaderCString, &shaderStringLen)
            glCompileShader(shader)
            
            var compileStatus : GLint = 0
            glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &compileStatus)
            
            if compileStatus == GL_FALSE {
                var infoLength : GLsizei = 0
                let bufferLength : GLsizei = 1024
                glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
                
                let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
                var actualLength : GLsizei = 0
                
                glGetShaderInfoLog(shader, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
                NSLog(String(validatingUTF8: info)!)
                exit(1)
            }
            print("load shader success "+file)
            return shader
        } catch {
            print("falsed load content string")
        }
        return 0
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
}
