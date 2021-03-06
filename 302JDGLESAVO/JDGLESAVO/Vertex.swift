//
//  Vertex.swift
//  JDGLESAVO
//
//  Created by wudong on 2018/12/14.
//  Copyright © 2018 jundong. All rights reserved.
//

import Foundation


struct Vertex {
    var x : GLfloat = 0.0
    var y : GLfloat = 0.0
    var z : GLfloat = 0.0
    
    var r : GLfloat = 0.0
    var g : GLfloat = 0.0
    var b : GLfloat = 0.0
    var a : GLfloat = 1.0
    
    
    init(_ x : GLfloat,
         _ y : GLfloat,
         _ z : GLfloat,
         _ r : GLfloat = 0.0,
         _ g : GLfloat = 0.0,
         _ b : GLfloat = 0.0
//         _ a : GLfloat = 1.0
        )
    {
        self.x = x
        self.y = y
        self.z = z
        
        self.r = r
        self.g = g
        self.b = b
//        self.a = a
    }
}
