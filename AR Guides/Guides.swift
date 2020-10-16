//
//  Guides.swift
//  ARMakrBuild
//
//  Created by Nien Lam on 2/3/20.
//  Copyright © 2020 Line Break, LLC. All rights reserved.
//

import SwiftUI
import RealityKit

class Guides {
    private static let shared = try! GuidesRC.loadMarkers()

    private init() { }

    static func makeAnchor() -> Entity {
        let entity = shared.findEntity(named: "Anchor")!.clone(recursive: true)
        entity.position = [0, 0, 0]
        return entity
    }

    static func makePlane() -> Entity {
        let entity = _GuidePlane()
        entity.position = [0, 0, 0]
        return entity
    }

    static func makeUnitBox() -> Entity {
        let entity = _GuideUnitBox()
        entity.position = [0, 0, 0]
        return entity
    }
    
    static func makeCursor() -> Entity {
        let entity = _GuideCursor()
        entity.position = [0, 0.01, 0]
        return entity
    }

    static func makeAxes() -> Entity {
        let greenArrow = shared.findEntity(named: "GreenArrow")!.clone(recursive: true)
        greenArrow.position = [0,0,0]

        let redArrow = shared.findEntity(named: "RedArrow")!.clone(recursive: true)
        redArrow.position = [0,0,0]

        let blueArrow = shared.findEntity(named: "BlueArrow")!.clone(recursive: true)
        blueArrow.position = [0,0,0]

        let box = MeshResource.generateBox(size: 0.01, cornerRadius: 0.001)
        let material = SimpleMaterial(color: .gray, isMetallic: false)
        let boxEntity = ModelEntity(mesh: box, materials: [material])
        
        boxEntity.addChild(blueArrow)
        boxEntity.addChild(redArrow)
        boxEntity.addChild(greenArrow)
        
        return boxEntity
    }

    static func makePointer() -> Entity {
        let arrow = shared.findEntity(named: "MagentaArrow")!.clone(recursive: true)
        arrow.position = [0,0,0]
        
        let box = MeshResource.generateBox(size: 0.01, cornerRadius: 0.001)
        let material = SimpleMaterial(color: .gray, isMetallic: false)
        let boxEntity = ModelEntity(mesh: box, materials: [material])

        boxEntity.addChild(arrow)

        return boxEntity
    }
}

class _GuidePlane: Entity, HasModel, HasCollision {
    required init() {
        super.init()

        var material = SimpleMaterial()
        let texture = try! TextureResource.load(named: "guides.grid")
        material.baseColor = MaterialColorParameter.texture(texture)

        self.components[ModelComponent] = ModelComponent(
            mesh: .generatePlane(width: 1.0, depth: 1.0),
            //            mesh: .generateBox(width: 1.0, height: 0.0, depth: 1.0),
            materials: [material]
        )
    
        self.name = "guide.plane"
        
        // self.generateCollisionShapes(recursive: false)
    }
}

class _GuideUnitBox: Entity, HasModel, HasCollision {
    required init() {
        super.init()

        var material = SimpleMaterial()
        let texture = try! TextureResource.load(named: "guides.grid")
        material.baseColor = MaterialColorParameter.texture(texture)

        self.components[ModelComponent] = ModelComponent(
            mesh: .generateBox(size: 0.1),
            materials: [material]
        )

        // self.generateCollisionShapes(recursive: false)
    }
}

class _GuideCursor: Entity, HasModel, HasCollision {
    required init() {
        super.init()

        let material = SimpleMaterial(color: UIColor.red.withAlphaComponent(0.75),
                                      isMetallic: false)

        self.components[ModelComponent] = ModelComponent(
            mesh: .generatePlane(width: 0.1, depth: 0.1, cornerRadius: 0.025),
            materials: [material]
        )

        // self.generateCollisionShapes(recursive: false)
    }
}
