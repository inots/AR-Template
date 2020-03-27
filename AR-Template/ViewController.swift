//
//  ViewController.swift
//  AR-Template
//
//  Created by loan on 3/26/20.
//  Copyright © 2020 inots. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //enable automatic lighting
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //add origin axis on view (for debuging)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //enable Plane Detection
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //function that creates a scene node for a plane
    //Takes a plane anchor as an argument - the plane detected
    //Returns a SCNNode - the plane created
    //Used for Experimentation with Plane Detection
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode{
        //create scene node
        let node = SCNNode()
        
        //create geometry -> generate plane of width & height specified by planeAnchor
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        //set the geometry created to the node
        node.geometry = geometry
        
        //change rotation (along x-axis) of plane
        node.eulerAngles.x = -Float.pi / 2
        //change opacity of plane
        node.opacity = 0.25
        
        return node
    }
    
    //function that creates a tree object and attaches it to a specific plane
    //Takes a plane anchor as an argument - the plane to which we have to attach the object
    //Returns a SCNNode - the newly created tree
    //Used for Experimentations with Plane Detection
    func createTree(planeAnchor: ARPlaneAnchor) -> SCNNode {
        //create a copy(clone) of the scene
        let node = SCNScene(named: "art.scnassets/tree.scn")!.rootNode.clone()
        
        //set position of node to be center of the plane given
        node.position = SCNVector3(planeAnchor.center.x, 0.0, planeAnchor.center.z)
        
        return node
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    //Experimentation with Plane Detection
    //method used to detect whenever a plane is found
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //detect plane in space
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        //create floor object and add to detected plane
        let floor = createFloor(planeAnchor: planeAnchor)
        node.addChildNode(floor)
        
        //create tree object and add to detected plane
        let tree = createTree(planeAnchor: planeAnchor)
        node.addChildNode(tree)
    }
    
    //Experimentation with Plane Detection
    //method used to update dimentions of plane as scene is updated
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor
            else {return}
        
        //loop through children of node and update their position to the center
        for node in node.childNodes {
            node.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            if let plane = node.geometry as? SCNPlane {
                //set plane position, width and height as detected from camera
                plane.width = CGFloat(planeAnchor.extent.x)
                plane.height = CGFloat(planeAnchor.extent.z)
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
