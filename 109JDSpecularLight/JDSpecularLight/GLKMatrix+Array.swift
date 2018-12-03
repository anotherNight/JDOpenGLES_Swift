//
//  GLKMatrix+Array.swift
//  JDModelOpenGLES
//
//  Created by wudong on 2018/11/22.
//  Copyright © 2018 jundong. All rights reserved.
//

import GLKit

extension GLKMatrix2 {
    var array: [Float] {
        return (0..<4).map { i in
            self[i]
        }
    }
}


extension GLKMatrix3 {
    var array: [Float] {
        return (0..<9).map { i in
            self[i]
        }
    }
}

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}
