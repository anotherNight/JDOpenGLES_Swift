//
//  Model.swift
//  JDModelOpenGLES
//
//  Created by wudong on 2018/11/22.
//  Copyright © 2018 jundong. All rights reserved.
//

import GLKit

class Model {
    var shader: BaseEffect!
    var name: String!
    var vertices: [Vertex]
    var vertexCount: GLuint!
    var indices: [GLubyte]
    var indexCount: GLuint!
    
    var vao: GLuint = 0
    var vertexBuffer: GLuint = 0
    var indexBuffer: GLuint = 0
    var texture: GLuint = 0
    var mask: GLuint = 0
    
    //model transformation
    var position: GLKVector3 = GLKVector3(v: (0.0, 0.0, 0.0))
    var rotationX: Float = 0.0
    var rotationY : Float = 0.0
    var rotationZ : Float = 0.0
    var scale : Float = 1.0
    
    init(name:String, shader: BaseEffect, vertices: [Vertex], indices: [GLubyte]) {
        self.name = name;
        self.shader = shader
        self.vertices = vertices
        self.vertexCount = GLuint(vertices.count)
        self.indices = indices
        self.indexCount = GLuint(indices.count)
        
        glGenVertexArraysOES(GLsizei(1), &vao)
        glBindVertexArrayOES(vao)
        
        glGenBuffers(GLsizei(1), &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        let count = vertices.count
        let size = MemoryLayout<Vertex>.size
        glBufferData(GLenum(GL_ARRAY_BUFFER), count*size, vertices, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(GLsizei(1), &indexBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<GLubyte>.size, indices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(VertexAttributes.position.rawValue)
        glVertexAttribPointer(VertexAttributes.position.rawValue, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(0))
        
        glEnableVertexAttribArray(VertexAttributes.color.rawValue)
        glVertexAttribPointer(VertexAttributes.color.rawValue, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET(3 * MemoryLayout<GLfloat>.size))
        
        glEnableVertexAttribArray(VertexAttributes.texCoord.rawValue)
        glVertexAttribPointer(VertexAttributes.texCoord.rawValue, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.size), BUFFER_OFFSET((3+4)*MemoryLayout<GLfloat>.size))
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
    }
    
    func modelMatrix() -> GLKMatrix4 {
        var modelMatrix: GLKMatrix4 = GLKMatrix4Identity
        modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationX, 1, 0, 0)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationY, 0, 1, 0)
        modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationZ, 0, 0, 1)
        modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale, self.scale, self.scale)
        return modelMatrix
    }
    
    func render() {
        shader.modelViewmatrix = modelMatrix()
        shader.prepareToDraw()

        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)

    }
    
    func renderWithParentModelViewMatrix(_ parentModelViewMatrix: GLKMatrix4) {
        let modelViewMatrix: GLKMatrix4 = GLKMatrix4Multiply(parentModelViewMatrix, modelMatrix())
        
        shader.modelViewmatrix = modelViewMatrix
        shader.texture = self.texture
        shader.mask = self.mask
        shader.prepareToDraw()
        
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }
    
    func updateWithDelta(_ dt: TimeInterval) {
        
    }
    
    func loadTexture(_ filename: String) -> GLuint {
        let path = Bundle.main.path(forResource: filename, ofType: nil)!
        let option = [GLKTextureLoaderOriginBottomLeft:true]
        do{
            let info = try GLKTextureLoader.texture(withContentsOfFile: path, options: option as [String:NSNumber]?)
            return info.name
        }catch {
            
        }
        return 0
    }
    
    func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
        return UnsafeRawPointer(bitPattern: n)
    }
    
}
