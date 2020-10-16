//
//  ViewController.swift
//  PlaneDetect
//
//  Created by Nien Lam on 10/8/20.
//

import UIKit
import ARKit
import RealityKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var myARView: ARView!

    // Outlet to label.
    @IBOutlet weak var myLabel: UILabel!
    
    // Outlet to test button.
    @IBOutlet weak var myTestButton: UIButton!
    @IBOutlet weak var birdSizeSlider: UISlider!
    @IBOutlet weak var mySpinButton: UIButton!
    
    // Root entity of Reality Composer Scene.
    var myEntities: Entity!
    
    // Anchor at position [0, 0, 0].
    var originAnchor: AnchorEntity!

    // Anchor tracks camera point of view.
    var cameraAnchor: AnchorEntity!

    // Cursor entity on horizontal or vertical surfaces.
    var cursor: Entity!
    
    // For callback methods.
    var subscriptions = Set<AnyCancellable>()

    // Counter variable.
    var counter: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load root entity from Reality Composer Project.
        myEntities = try! Experience.loadMyEntities()
        
        // Create and add origin anchor.
        originAnchor = AnchorEntity(world: float4x4(1))
        myARView.scene.addAnchor(originAnchor)
        
        // Create and add camera anchor.
        cameraAnchor = AnchorEntity(.camera)
        myARView.scene.addAnchor(cameraAnchor)

        // Add cursor. Tracks on horizontal and vertical planes.
        cursor = Guides.makeCursor()
        originAnchor.addChild(cursor)
        
        // Called every frame.
        myARView.scene.subscribe(to: SceneEvents.Update.self) { event in
            // Update cursor position.
            self.updateCursor()
        }.store(in: &subscriptions)

        // Setup tap gesture for entire screen.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        myARView.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Running on device.
        #if !targetEnvironment(simulator)
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal, .vertical]
            myARView.session.run(configuration)
        #endif
    }

    private func updateCursor() {
        // Raycast to get cursor position.
        let results = myARView.raycast(from: self.view.center,
                                       allowing: .existingPlaneGeometry,
                                       alignment: .any)
            
        // Move cursor to position if hitting plane.
        if let result = results.first {
            cursor.isEnabled = true
            cursor.move(to: result.worldTransform, relativeTo: originAnchor)
        } else {
            cursor.isEnabled = false
        }
    }

    ////////
    // Called when tapped anywhere on the screen.
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        let touchInView = sender.location(in: self.myARView)

        if let hitEntity = self.myARView.entity(at: touchInView) {
            print("➡️ TAPPED A ENTITY:", hitEntity.parent!.name)
            if birdSizeSlider.value <= 0.5 {
                // Set label to entity name.
            myLabel.text = "Dera# \(counter) is tiny!"
            }
            if  birdSizeSlider.value > 0.5 && birdSizeSlider.value < 1.0 {
            myLabel.text = "Dera# \(counter) is fit!"
            }
            if  birdSizeSlider.value >= 1.0 {
            myLabel.text = "Dera# \(counter) is fat!"
            }
        }
    }

    ////////
    // Called when UI Button is tapped.
    @IBAction func didTapTestButton(_ sender: Any) {
        print("➡️ TAPPED TEST BUTTON")
        
        // Get clone of whiteBird entity.
        // Note: Entity name must match from Reality Composer or this will cause a crash.
        let whiteBird = myEntities.findEntity(named: "White Bird")!.clone(recursive: true)
        whiteBird.transform.translation = [0,0,0]

        // Append counter number to name.
        whiteBird.name = "MyClonedFirstRound_" + "\(counter)"
    
        // IMPORTANT: Need to set so hit detection works.
        whiteBird.generateCollisionShapes(recursive: true)

        // Move box to cursor.
        whiteBird.transform.matrix = cursor.transformMatrix(relativeTo: originAnchor)
        // Update button title.
        myTestButton.setTitle("Number of Dera: \(counter + 1)", for: .normal)
        
        // Increment counter.
        counter += 1
        
        // Add box to origin anchor.
        whiteBird.transform.scale = [Float(birdSizeSlider.value),Float(birdSizeSlider.value),Float(birdSizeSlider.value)]
        originAnchor.addChild(whiteBird)

        

    }

    // NOTE: ADD NEW IBACTIONS BELOW HERE:
    @IBAction func scaleModif(_ sender: UISlider){
    
    }
    @IBAction func spinTheBird(_ sender: UIButton){
        print("spin tapped")
    }


}
