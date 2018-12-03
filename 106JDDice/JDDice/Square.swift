//
//  Square.swift
//  JDModelOpenGLES
//
//  Created by wudong on 2018/11/22.
//  Copyright © 2018 jundong. All rights reserved.
//

import GLKit

class Square: Model {
    let vertexList : [Vertex] = [
        Vertex( 1.0, -1.0, 0, 1.0, 0.0, 0.0, 1.0),
        Vertex( 1.0,  1.0, 0, 0.0, 1.0, 0.0, 1.0),
        Vertex(-1.0,  1.0, 0, 0.0, 0.0, 1.0, 1.0),
        Vertex(-1.0, -1.0, 0, 1.0, 1.0, 0.0, 1.0)
    ]
    
    let indexList : [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    init(shader: BaseEffect) {
        super.init(name: "square", shader: shader, vertices: vertexList, indices: indexList)
    }
    
    override func updateWithDelta(_ dt: TimeInterval) {
        let secsPerMove = 2.0
        self.position = GLKVector3Make(
            Float(sin(CACurrentMediaTime() * 2 * Double.pi / secsPerMove)),
            self.position.y,
            self.position.z)
    }
    
}
