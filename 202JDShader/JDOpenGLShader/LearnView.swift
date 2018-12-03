//
//  LearnView.swift
//  JDOpenGLShader
//
//  Created by wudong on 2018/11/29.
//  Copyright © 2018 jundong. All rights reserved.
//

import UIKit
import GLKit

class LearnView: UIView {
    
    var myContext: EAGLContext!
    var myEagLayer: CAEAGLLayer!
    var myProgram: GLuint = 0
    
    var myColorRenderBuffer: GLuint = 0
    var myColorFrameBuffer: GLuint = 0
    
    var attrArr : [Vertex] = [
        Vertex(0.5, -0.5, -1.0, 1.0, 0.0),
        Vertex(-0.5, 0.5, -1.0, 0.0, 1.0),
        Vertex(-0.5, -0.5, -1.0, 0.0, 0.0),
        Vertex(0.5, 0.5, -1.0, 1.0, 1.0),
        Vertex(-0.5, 0.5, -1.0, 0.0, 1.0),
        Vertex(0.5, -0.5, -1.0, 1.0, 0.0),
        ]
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
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
        self.myEagLayer = self.layer as! CAEAGLLayer
        self.contentScaleFactor = UIScreen.main.scale
        self.myEagLayer.isOpaque = true
        
        let options:[String:Any] = [kEAGLDrawablePropertyRetainedBacking:false,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8]
        self.myEagLayer.drawableProperties = options
    }
    
    func setupContext() {
        if let context = EAGLContext.init(api: EAGLRenderingAPI.openGLES2){
            if EAGLContext.setCurrent(context){
                self.myContext = context
            }else{
                print("failed to set current OpenGL context")
            }
        }else{
            print("failed to initialize OpenGLES 2.0 context")
        }
        
    }
    
    func destoryRenderAndFrameBuffer() {
        
        glDeleteRenderbuffers(GLsizei(1), &myColorRenderBuffer)
        self.myColorRenderBuffer = 0
        glDeleteFramebuffers(GLsizei(1), &myColorFrameBuffer)
        self.myColorFrameBuffer = 0
    }
    
    func setupRenderBuffer() {
        
        glGenBuffers(1, &myColorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), myColorRenderBuffer)
        // 为 颜色缓冲区 分配存储空间
        self.myContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.myEagLayer)
    }
    
    func setupFrameBuffer() {
        glGenFramebuffers(1, &myColorFrameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), myColorFrameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.myColorFrameBuffer)
    }
    
    func render() {
        glClearColor(0, 1.0, 0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let scale = UIScreen.main.scale
        glViewport(GLint(self.frame.minX*scale), GLint(self.frame.minY*scale), GLsizei(self.frame.width*scale), GLsizei(self.frame.height*scale))

        self.myProgram = self.load(shadersName: "shaderv.vsh", fragName: "shaderf.fsh")

        glLinkProgram(self.myProgram)
        var linkStatus:GLint = 0
        glGetProgramiv(self.myProgram, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(self.myProgram, GLenum(GL_INFO_LOG_LENGTH), &infoLength)

            let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0

            glGetProgramInfoLog(self.myProgram, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            NSLog(String(validatingUTF8: info)!)
            exit(1)
        }

        print("line success")
        glUseProgram(self.myProgram)

        var attrBuffer: GLuint = 0
        glGenBuffers(1, &attrBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), attrBuffer)
        let count = attrArr.count
        let size = MemoryLayout<Vertex>.size
        glBufferData(GLenum(GL_ARRAY_BUFFER), count*size, attrArr, GLenum(GL_DYNAMIC_DRAW))

        let position: GLuint = GLuint(glGetAttribLocation(self.myProgram, "position"))
        glVertexAttribPointer(position, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        glEnableVertexAttribArray(position)

        let texCoor: GLuint = GLuint(glGetAttribLocation(self.myProgram, "textCoordinate"))
        glVertexAttribPointer(texCoor, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3*MemoryLayout<GLfloat>.size))
        glEnableVertexAttribArray(texCoor)

        self.setupTexture(fileName: "opengl_test.jpg")

        let rotate = glGetUniformLocation(self.myProgram, "rotateMatrix")

        let radians = 10*3.14159 / 180.0
        let s = sin(radians)
        let c = cos(radians)

        let zRotation: [GLfloat] = [
            Float(c), Float(-s), 0, 0.2, //
            Float(s), Float(c), 0, 0,//
            0, 0, 1.0, 0,//
            0.0, 0, 0, 1.0//
        ]

        glUniformMatrix4fv(GLint(rotate), 1, GLboolean(GL_FALSE), zRotation)

        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(self.attrArr.count))
        
        self.myContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
        
        
        
    }
    
    func load(shadersName:String, fragName:String) -> GLuint {
        let verShader: GLuint = self.compile(type:GLenum(GL_VERTEX_SHADER), file: shadersName)
        let fragShader: GLuint = self.compile(type:GLenum(GL_FRAGMENT_SHADER), file: fragName)
        
        let program = glCreateProgram()
        
        glAttachShader(program, verShader)
        glAttachShader(program, fragShader)
        
        glDeleteShader(verShader)
        glDeleteShader(fragShader)
        
        return program
    }
    
    func compile(type: GLenum, file:String) -> GLuint {
        let path = Bundle.main.path(forResource: file, ofType: nil)
        do {
            let shaderString = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            var shaderCString = shaderString.utf8String
            var shaderStringLength : GLint = GLint(Int32(shaderString.length))
            let shader = glCreateShader(type)
            
            glShaderSource(shader, GLsizei(1), &shaderCString, &shaderStringLength)
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
            return shader
        }catch {
            
        }
        return 0
    }
    
    func setupTexture(fileName:String) {
        let path = Bundle.main.path(forResource: fileName, ofType: nil)
        if path == nil {
            print("texture no at path \(String(describing: path))")
            exit(1)
        }
        
        if let image: UIImage = UIImage(contentsOfFile: path!) {
            if let spriteImage: CGImage = image.cgImage {
                let width:Int = spriteImage.width
                let height:Int = spriteImage.height
                print("image width: \(width),height: \(height)")
//                let pixels = UnsafeMutablePointer<GLubyte>.allocate(capacity: width*height*4)
//                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let spriteData = calloc(width*height*4, MemoryLayout<GLubyte>.size)
                let spriteContext: CGContext = CGContext.init(data: spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width*4, space: spriteImage.colorSpace!, bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
                spriteContext.draw(spriteImage, in: CGRect(x: 0, y: 0, width: width, height: height))
                
                //'CGContextRelease' is unavailable: Core Foundation objects are automatically memory managed
                //CGContextRelease
                
                //MARK: ???
                glBindTexture(GLenum(GL_TEXTURE_2D), 0)
                
                glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLfloat(GL_LINEAR))
                glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLfloat(GL_LINEAR))
                glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
                glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
                
                glTexImage2D(GLenum(GL_TEXTURE_2D), GLint(0), GL_RGBA, GLsizei(width), GLsizei(height), GLint(0), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), spriteData)
                glBindTexture(GLenum(GL_TEXTURE_2D), 0)
                
//                free(spriteData)
            }else {
                print("falsed load cgimage")
            }
        }else{
            print("falsed load image")
        }
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
}
