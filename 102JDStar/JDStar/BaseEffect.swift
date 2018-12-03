//
//  BaseEffect.swift
//  JDStar
//
//  Created by wudong on 2018/11/21.
//  Copyright © 2018 jundong. All rights reserved.
//

import Foundation
import GLKit

class BaseEffect {
    var programhandle : GLuint = 0
    
    init(vertexShader: String, fragmentShader: String) {
        self.compile(vertexShader: vertexShader, fragmentShader: fragmentShader)
    }
    
    func prepareToDraw() {
        //当调用glUseProgram时，这些可执行文件成为当前状态的一部分。
        //可以通过调用glDeleteProgram删除程序对象。 当program 对象不再是任何上下文的当前呈现状态的一部分时，将删除与program 对象关联的内存。
        glUseProgram(self.programhandle)
    }
}


extension BaseEffect {
    func compile(vertexShader: String, fragmentShader: String) {
        let vertexShaderName = self.compileShader(vertexShader, shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShaderName = self.compileShader(fragmentShader, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        //create program object
        //glCreateProgram创建一个空program并返回一个可以被引用的非零值（program ID）。
        //program对象是可以附加着色器对象的对象。
        //这提供了一种机制来指定将链接以创建program的着色器对象。
        //它还提供了一种检查将用于创建program的着色器的兼容性的方法（例如，检查顶点着色器和片元着色器之间的兼容性）。
        //当不再需要作为program对象的一部分时，着色器对象就可以被分离了。
        //通过调用glCompileShader成功编译着色器对象，并且通过调用glAttachShader成功地将着色器对象附加到program 对象，并且通过调用glLinkProgram成功的链接program 对象之后，可以在program 对象中创建一个或多个可执行文件。
        self.programhandle = glCreateProgram()
        //将着色器对象附加到program对象
        glAttachShader(self.programhandle, vertexShaderName)
        glAttachShader(self.programhandle, fragmentShaderName)
        //Bind VertexAttributes.vertexAttribPosition.rawValue to the shader input variable "a_Position"
        //在shader初始化时已经设置了VertexAttributes.vertexAttribPosition数据
        glBindAttribLocation(self.programhandle, VertexAttributes.vertexAttribPosition.rawValue, "a_Position")
        //link program object
        //glLinkProgram链接program指定的program对象。
        //附加到program的类型为GL_VERTEX_SHADER的着色器对象用于创建将在可编程顶点处理器上运行的可执行文件。
        //附加到program的类型为GL_FRAGMENT_SHADER的着色器对象用于创建将在可编程片段处理器上运行的可执行文件。
        glLinkProgram(self.programhandle)
        
        var linkStatus : GLint = 0
        //从program对象返回一个参数的值,这里是返回上一个操作的status，即glLinkProgram（）的status
        //1.program: program object
        //2.pname: program object parameter，eg：GL_DELETE_STATUS，GL_LINK_STATUS，GL_VALIDATE_STATUS，GL_INFO_LOG_LENGTH，GL_ATTACHED_SHADERS，GL_ACTIVE_ATTRIBUTES，GL_ACTIVE_UNIFORMS，GL_ACTIVE_ATTRIBUTE_MAX_LENGTH，GL_ACTIVE_UNIFORM_MAX_LENGTH
        glGetProgramiv(self.programhandle, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(self.programhandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            // get program info log
            glGetProgramInfoLog(self.programhandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            print(String(validatingUTF8: info)!)
            exit(1)
        }
    }
    
//     GL_FRAGMENT_SHADER 0x8B30 // 代表片元着色器类型对象
//     GL_VERTEX_SHADER   0x8B31 // 代表顶点着色器类型对象

    func compileShader(_ shadername: String, shaderType: GLenum) -> GLuint {
        let path = Bundle.main.path(forResource: shadername, ofType: nil)
        
        do {
            let shaderString = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            let shaderHandle = glCreateShader(shaderType)
            var shaderStringLength : GLint = GLint(Int32(shaderString.length))
            var shaderCString = shaderString.utf8String
            //替换着色器对象中的源代码
            //1.shader: 要被替换源代码的shader object的句柄ID
            //2.count： 指定字符串和长度数组中的元素数
            //3.string：指定指向包含要加载到着色器的源代码的字符串的指针数组
            //4.length： 指定字符串长度的数组
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
                print(String(validatingUTF8: info)!)
                exit(1)
            }
            return shaderHandle
            
        }catch {
            exit(1)
        }
    }
}
