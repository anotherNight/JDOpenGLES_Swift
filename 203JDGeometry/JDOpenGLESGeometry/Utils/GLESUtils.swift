//
//  GLESUtils.swift
//  JDOpenGLESGeometry
//
//  Created by wudong on 2018/12/3.
//  Copyright © 2018 jundong. All rights reserved.
//

import Foundation
import OpenGLES

class GLESUtils: NSObject {
    class func load(type:GLenum,shaderString:NSString) -> GLuint {
        var shaderHandle = glCreateShader(type)

        var shaderCString = shaderString.utf8String
        glShaderSource(shaderHandle, 1, &shaderCString, nil)
        
        glCompileShader(shaderHandle)
        
        var compiled:GLint = 0
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compiled)
        if compiled == GL_FALSE {
            var infolen: GLint = 0
            let bufferLength: GLsizei = 1024
            
            glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &infolen)
            
            let info: [GLchar] = Array(repeating: GLchar(0), count: Int(infolen))
            var actualLength: GLsizei = 0
            glGetShaderInfoLog(shaderHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            print(String(validatingUTF8: info)!)
            exit(1)
        }
        return shaderHandle
    }
    
    class func load(type:GLenum,filePath:String) -> GLuint {
        do {
            let shaderString = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue)
            return self.load(type: type, shaderString: shaderString)
        } catch {
            print("faild load filePath \(filePath)")
        }
        return 0
    }
    
    class func loadProgram(vShaderFilePath:String,fShaderFilePath:String) -> GLuint {
        var vertexShader:GLuint = self.load(type: GLenum(GL_VERTEX_SHADER), filePath: vShaderFilePath)
        var fragmentShader = self.load(type: GLenum(GL_FRAGMENT_SHADER), filePath: fShaderFilePath)
        
        if fragmentShader == 0 || vertexShader == 0 {
            return 0
        }
        var programHandle = glCreateProgram()
        if programHandle == 0 {
            return 0
        }
        
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        
        glLinkProgram(programHandle)
        
        var linkStatus: GLint = 0
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLen: GLint = 0
            var bufferLength:GLsizei = 2014
            
            glGetProgramiv(programHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLen)
            
            let info: [GLchar] = Array(repeating: GLchar(0), count: Int(infoLen))
//            let info = malloc(MemoryLayout<GLchar>.size*Int(infoLen))
            var actualLength: GLsizei = 0

            glGetProgramInfoLog(programHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            print("error link program : " + String(validatingUTF8: info)!)
            exit(1)
        }
        glDeleteProgram(programHandle)
        return 0
    }
}
