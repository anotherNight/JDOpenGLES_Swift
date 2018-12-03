//
//  MaskdSquare.swift
//  JDMasking
//
//  Created by wudong on 2018/11/23.
//  Copyright © 2018 jundong. All rights reserved.
//

import GLKit

class MaskedSquare: Model {
    let vertexList : [Vertex] = [
        Vertex( 1.0, -1.0, 0, 1.0, 1.0, 1.0, 1.0, 1, 0),
        Vertex( 1.0,  1.0, 0, 1.0, 1.0, 1.0, 1.0, 1, 1),
        Vertex(-1.0,  1.0, 0, 1.0, 1.0, 1.0, 1.0, 0, 1),
        Vertex(-1.0, -1.0, 0, 1.0, 1.0, 1.0, 1.0, 0, 0)
    ]
    
    let indexList : [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    init(shader: BaseEffect, texture: String, mask: String?) {
        super.init(name: "masked-square", shader: shader, vertices: vertexList, indices: indexList)
        self.texture = self.loadTexture(texture)
        if let m = mask {
            self.mask = self.loadTexture(m)
        }
    }
    
    override func updateWithDelta(_ dt: TimeInterval) {
        let secsPerMove = 2.0
        self.position = GLKVector3Make(
            Float(sin(CACurrentMediaTime() * 2 * Double.pi / secsPerMove)),
            self.position.y,
            self.position.z)
    }
}
