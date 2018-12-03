//
//  Vertex.swift
//  JDStar
//
//  Created by wudong on 2018/11/21.
//  Copyright © 2018 jundong. All rights reserved.
//

import Foundation
import GLKit

enum VertexAttributes: GLuint {
    case vertexAttribPosition = 0
}

struct Vertex {
    var x : GLfloat = 0.0
    var y : GLfloat = 0.0
    var z : GLfloat = 0.0
    
    init(_ x : GLfloat, _ y : GLfloat, _ z : GLfloat) {
        self.x = x
        self.y = y
        self.z = z
    }
}
