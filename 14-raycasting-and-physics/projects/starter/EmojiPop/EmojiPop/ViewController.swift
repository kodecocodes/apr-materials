/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {
  
  @IBOutlet var sceneView: ARSKView!
  @IBOutlet weak var hudLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and node count
    sceneView.showsFPS = true
    sceneView.showsNodeCount = true
    
    // Load the SKScene from 'Scene.sks'
    if let scene = SKScene(fileNamed: "Scene") {
      sceneView.presentScene(scene)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    // Run the view's session
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  // MARK: - ARSKViewDelegate
  
  func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
    // Create and configure a node for the anchor added to the view's session.
    let spawnNode = SKNode()
    spawnNode.name = "SpawnPoint"
    let boxNode = SKLabelNode(text: "🆘")
    boxNode.verticalAlignmentMode = .center
    boxNode.horizontalAlignmentMode = .center
    boxNode.zPosition = 100
    boxNode.setScale(1.5)
    spawnNode.addChild(boxNode)
    return spawnNode
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    showAlert("Session Failure", error.localizedDescription)
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .normal: break
    case .notAvailable:
      showAlert("Tracking Limited", "AR not available")
      break
    case .limited(let reason):
      switch reason {
      case .initializing, .relocalizing: break
      case .excessiveMotion:
        showAlert("Tracking Limited", "Excessive motion!")
        break
      case .insufficientFeatures:
        showAlert("Tracking Limited", "Insufficient features!")
        break
      default: break
      }
    }
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    showAlert("AR Session", "Session was interrupted!")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    let scene = sceneView.scene as! Scene
    scene.startGame()
  }
  
  func showAlert(_ title: String, _ message: String) {
    let alert = UIAlertController(title: title, message: message,
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK",
      style: UIAlertAction.Style.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}
