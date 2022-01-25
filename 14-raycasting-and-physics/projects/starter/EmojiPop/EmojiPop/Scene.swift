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

import SpriteKit
import ARKit

public enum GameState {
  case Init
  case TapToStart
  case Playing
  case GameOver
}

class Scene: SKScene {
  
  var gameState = GameState.Init
  var anchor: ARAnchor?
  var emojis = "😁😂😛😝😋😜🤪😎🤓🤖🎃💀🤡"
  var spawnTime : TimeInterval = 0
  var score : Int = 0
  var lives : Int = 10
  
  override func didMove(to view: SKView) {
    startGame()
  }
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    switch (gameState)
    {
      case .Init:
        break
      case .TapToStart:
        playGame()
        break
      case .Playing:
        //checkTouches(touches)
        break
      case .GameOver:
        startGame()
        break
    }
  }
  
  func updateHUD(_ message: String) {
    guard let sceneView = self.view as? ARSKView else {
      return
    }
    let viewController = sceneView.delegate as! ViewController
    viewController.hudLabel.text = message
  }
  
  public func startGame() {
    gameState = .TapToStart
    updateHUD("- TAP TO START -")
    removeAnchor()
  }
  
  public func playGame() {
    gameState = .Playing
    score = 0
    lives = 10
    spawnTime = 0
    addAnchor()
  }
  
  public func stopGame() {
    gameState = .GameOver
    updateHUD("GAME OVER! SCORE: " + String(score))
  }
  
  func addAnchor() {
    guard let sceneView = self.view as? ARSKView else {
      return
    }

    if let currentFrame = sceneView.session.currentFrame {
      var translation = matrix_identity_float4x4
      translation.columns.3.z = -0.5
      let transform = simd_mul(currentFrame.camera.transform, translation)
      anchor = ARAnchor(transform: transform)
      sceneView.session.add(anchor: anchor!)
    }
  }
  
  func removeAnchor() {
    guard let sceneView = self.view as? ARSKView else {
      return
    }
    if anchor != nil {
      sceneView.session.remove(anchor: anchor!)
    }
  }
}
