//
//  Vertex.swift
//  JDOpengGLESBase
//
//  Created by wudong on 2018/11/28.
//  Copyright © 2018 jundong. All rights reserved.
//

import Foundation
import GLKit

struct Vertex {
    var x : GLfloat = 0.0
    var y : GLfloat = 0.0
    var z : GLfloat = 0.0
    
    var u : GLfloat = 0.0
    var v : GLfloat = 0.0
    
    init(_ x : GLfloat, _ y : GLfloat, _ z : GLfloat, _ u : GLfloat = 0.0, _ v : GLfloat = 0.0) {
        self.x = x
        self.y = y
        self.z = z
        
        self.u = u
        self.v = v
    }

}
