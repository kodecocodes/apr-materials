/// Copyright (c) 2020 Razeware LLC
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
import SceneKit
import ARKit

// MARK: - App State Management

enum AppState: Int16 {
  case DetectSurface  // Scan surface (Plane Detection On)
  case PointAtSurface // Point at surface to see focus point (Plane Detection Off)
  case TapToStart     // Focus point visible on surface, tap to start
  case Started
}

// MARK: - UIViewController

class ViewController: UIViewController, ARSCNViewDelegate {
  
  // MARK: - Properties
  var trackingStatus: String = ""
  var statusMessage: String = ""
  var appState: AppState = .DetectSurface
  
  // MARK: - IB Outlets
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - IB Actions
  @IBAction func resetButtonPressed(_ sender: Any) {
    self.resetApp()
  }
  
  @IBAction func tapGestureHandler(_ sender: Any) {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initScene()
    self.initCoachingOverlayView()
    self.initARSession()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("*** ViewWillAppear()")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    print("*** ViewWillDisappear()")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    print("*** DidReceiveMemoryWarning()")
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}

// MARK: - App Management

extension ViewController {
  
  func startApp() {
    DispatchQueue.main.async {
      self.appState = .DetectSurface
    }
  }
  
  func resetApp() {
    DispatchQueue.main.async {
      self.resetARSession()
      self.appState = .DetectSurface
    }
  }
}

// MARK: - AR Coaching Overlay

extension ViewController : ARCoachingOverlayViewDelegate {
  
  func initCoachingOverlayView() {
    let coachingOverlay = ARCoachingOverlayView()
    coachingOverlay.session = self.sceneView.session
    coachingOverlay.delegate = self
    coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
    coachingOverlay.activatesAutomatically = true
    coachingOverlay.goal = .horizontalPlane
    self.sceneView.addSubview(coachingOverlay)
    
    NSLayoutConstraint.activate([
      NSLayoutConstraint(item:  coachingOverlay, attribute: .top, relatedBy: .equal,
                         toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item:  coachingOverlay, attribute: .bottom, relatedBy: .equal,
                         toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item:  coachingOverlay, attribute: .leading, relatedBy: .equal,
                         toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item:  coachingOverlay, attribute: .trailing, relatedBy: .equal,
                         toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
    ])
  }
  
  func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
  }
  
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    self.startApp()
  }
  
  func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    self.resetApp()
  }
}

// MARK: - AR Session Management (ARSCNViewDelegate)

extension ViewController {
    
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: AR World Tracking Not Supported")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.planeDetection = .horizontal
    config.isLightEstimationEnabled = true
    config.environmentTexturing = .automatic
    sceneView.session.run(config)
  }
  
  func resetARSession() {
    let config = sceneView.session.configuration as!
      ARWorldTrackingConfiguration
    config.planeDetection = .horizontal
    sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .notAvailable:
      self.trackingStatus = "Tracking:  Not available!"
    case .normal:
      self.trackingStatus = ""
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        self.trackingStatus = "Tracking: Limited due to excessive motion!"
      case .insufficientFeatures:
        self.trackingStatus = "Tracking: Limited due to insufficient features!"
      case .relocalizing:
        self.trackingStatus = "Tracking: Relocalizing..."
      case .initializing:
        self.trackingStatus = "Tracking: Initializing..."
      @unknown default:
        self.trackingStatus = "Tracking: Unknown..."
      }
    }
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    self.trackingStatus = "AR Session Failure: \(error)"
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    self.trackingStatus = "AR Session Was Interrupted!"
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    self.trackingStatus = "AR Session Interruption Ended"
  }
}

// MARK: - Scene Management

extension ViewController {
  
  func initScene() {
    let scene = SCNScene()
    sceneView.scene = scene
    sceneView.delegate = self
  }
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateStatus()
    }
  }
  
  func updateStatus() {
    switch appState {
    case .DetectSurface:
      statusMessage = "Scan available flat surfaces..."
    case .PointAtSurface:
      statusMessage = "Point at designated surface first!"
    case .TapToStart:
      statusMessage = "Tap to start."
    case .Started:
      statusMessage = "Tap objects for more info."
    }
    
    self.statusLabel.text = trackingStatus != "" ?
      "\(trackingStatus)" : "\(statusMessage)"
  }
}

// MARK: - Focus Node Management

