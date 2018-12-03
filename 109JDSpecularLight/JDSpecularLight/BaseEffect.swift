//
//  BaseEffect.swift
//  JDModelOpenGLES
//
//  Created by wudong on 2018/11/22.
//  Copyright © 2018 jundong. All rights reserved.
//

import Foundation
import GLKit

class BaseEffect {
    var programHandle: GLuint = 0
    var modelViewmatrixuniform: Int32 = 0
    var projectionMatrixUniform: Int32 = 0
    var textureUniform: Int32 = 0
    var lightColorUniform: Int32 = 0
    var lightAmbientIntensityUniform: Int32 = 0
    var lightDiffuseIntensityUniform : Int32 = 0
    var lightDirectionUniform : Int32 = 0
    var lightSpecularIntensityUniform : Int32 = 0
    var lightShininessUniform : Int32 = 0
    
    var modelViewmatrix: GLKMatrix4 = GLKMatrix4Identity
    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity
    var texture: GLuint = 0
    
    init(vertexShader:String, fragmentShader: String) {
        self.compile(vertexShader: vertexShader, fragmentShader: fragmentShader)
    }
    
    func prepareToDraw() {
        glUseProgram(self.programHandle)
        
        glUniformMatrix4fv(self.modelViewmatrixuniform, 1, GLboolean(GL_FALSE), self.modelViewmatrix.array)
        
        glUniformMatrix4fv(self.projectionMatrixUniform, GLsizei(1), GLboolean(GL_FALSE), self.projectionMatrix.array)
        
        //设置激活的纹理单元
        glActiveTexture(GLenum(GL_TEXTURE1))
        //绑定纹理对象
        glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
        //使用glUniform1i，我们可以给纹理采样器分配一个位置值，这样的话我们能够在一个片段着色器中设置多个纹理。
        //一个纹理的位置值通常称为一个纹理单元(Texture Unit)。一个纹理的默认纹理单元是0
        glUniform1i(self.textureUniform, 1)
        
        //light
        glUniform3f(self.lightColorUniform, 1,1,1)
        glUniform1f(self.lightAmbientIntensityUniform, 0.1)
        
        //diffuse
        let lightDirection : GLKVector3 = GLKVector3(v: (0, 1, -1))
        glUniform3f(self.lightDirectionUniform, lightDirection.x, lightDirection.y, lightDirection.z)
        glUniform1f(self.lightDiffuseIntensityUniform, 0.7)
        
        //specular
        glUniform1f(self.lightSpecularIntensityUniform, 2.0)
        glUniform1f(self.lightShininessUniform, 1.0)
        
    }
}

extension BaseEffect {
    func compileShader(_ shaderName: String, shaderType: GLenum) -> GLuint {
        let path = Bundle.main.path(forResource: shaderName, ofType: nil)
        do {
            let shaderString = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            let shaderHandle = glCreateShader(shaderType)
            var shaderStringLength : GLint = GLint(Int32(shaderString.length))
            var shaderCString = shaderString.utf8String
            glShaderSource(shaderHandle, GLsizei(1), &shaderCString, &shaderStringLength)
            
            glCompileShader(shaderHandle)
            var compileStatus : GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
            
            if compileStatus == GL_FALSE {
                var infoLength : GLsizei = 0
                let bufferLength : GLsizei = 1024
                glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
                
                let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
                var actualLength : GLsizei = 0
                
                glGetShaderInfoLog(shaderHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
                NSLog(String(validatingUTF8: info)!)
                exit(1)
            }
            
            return shaderHandle
            
        }catch {
            exit(1)
        }
    }
    
    func compile(vertexShader: String, fragmentShader: String) {
        let vertexShaderName = self.compileShader(vertexShader, shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShaderName = self.compileShader(fragmentShader, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        self.programHandle = glCreateProgram()
        glAttachShader(self.programHandle, vertexShaderName)
        glAttachShader(self.programHandle, fragmentShaderName)
        
        glBindAttribLocation(self.programHandle, VertexAttributes.position.rawValue, "a_Position")
        glBindAttribLocation(self.programHandle, VertexAttributes.color.rawValue, "a_Color")
        glBindAttribLocation(self.programHandle, VertexAttributes.texCoord.rawValue, "a_TexCoord")
        glBindAttribLocation(self.programHandle, VertexAttributes.normal.rawValue, "a_Normal") // 노말벡터 좌표 보내는 곳을 a_Normal 어트리뷰트로 바인딩한다.
        glLinkProgram(self.programHandle)
        
        self.modelViewmatrixuniform = glGetUniformLocation(self.programHandle, "u_ModelViewMatrix")
        self.projectionMatrixUniform = glGetUniformLocation(self.programHandle, "u_ProjectionMatrix")
        self.textureUniform = glGetUniformLocation(self.programHandle, "u_Texture")
        self.lightColorUniform = glGetUniformLocation(self.programHandle, "u_Light.Color")
        self.lightAmbientIntensityUniform = glGetUniformLocation(self.programHandle, "u_Light.AmbientIntensity")
        self.lightDiffuseIntensityUniform = glGetUniformLocation(self.programHandle, "u_Light.DiffuseIntensity")
        self.lightDirectionUniform = glGetUniformLocation(self.programHandle, "u_Light.Direction")
        self.lightSpecularIntensityUniform = glGetUniformLocation(self.programHandle, "u_Light.SpecularIntensity")
        self.lightShininessUniform = glGetUniformLocation(self.programHandle, "u_Light.Shininess")

        var linkStatus : GLint = 0
        glGetProgramiv(self.programHandle, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(self.programHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(self.programHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            NSLog(String(validatingUTF8: info)!)
            exit(1)
        }
    }
}
