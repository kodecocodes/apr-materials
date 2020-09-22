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

import SwiftUI
import RealityKit
import ARKit

var arView: ARView!

struct ContentView : View {
  
  @State var propId: Int = 0
  
  var body: some View {
    ZStack(alignment: .bottom) {
      ARViewContainer(propId: $propId).edgesIgnoringSafeArea(.all)
      HStack {
        
        Spacer()
        
        Button(action: {
          self.propId = self.propId <= 0 ? 0 : self.propId - 1
        }) {
          Image("PreviousButton").clipShape(Circle())
        }
        
        Spacer()
        
        Button(action: {
          self.TakeSnapshot()
        }) {
          Image("ShutterButton")
            .clipShape(Circle())
        }
        
        Spacer()
        
        Button(action: {
          self.propId = self.propId >= 2 ? 2 : self.propId + 1
        }) {
          Image("NextButton").clipShape(Circle())
        }
        
        Spacer()
      }
    }
  }
  
  func TakeSnapshot() {
    arView.snapshot(saveToHDR: false) { (image) in
      let compressedImage = UIImage(data: (image?.pngData())!)
      UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
    }
  }
}

struct ARViewContainer: UIViewRepresentable {
  
  @Binding var propId: Int
  
  func makeUIView(context: Context) -> ARView {
    arView = ARView(frame: .zero)
    return arView
  }
  
  func updateUIView(_ uiView: ARView, context: Context) {
    arView.scene.anchors.removeAll()
    
    let arConfiguration = ARFaceTrackingConfiguration()
    uiView.session.run(arConfiguration, options:[.resetTracking, .removeExistingAnchors])
    
    switch(propId) {
    case 0: // Eyes
      let arAnchor = try! Experience.loadEyes()
      uiView.scene.anchors.append(arAnchor)
      break
    case 1: // Glasses
      let arAnchor = try! Experience.loadGlasses()
      uiView.scene.anchors.append(arAnchor)
      break
    case 2: // Mustache
      let arAnchor = try! Experience.loadMustache()
      uiView.scene.anchors.append(arAnchor)
      break
    default:
      break
    }
  }  
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
#endif
