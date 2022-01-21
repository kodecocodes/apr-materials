/// Copyright © 2020 Apple Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a
/// copy of this software and associated documentation files (the "Software"),
/// to deal in the Software without restriction, including without limitation the
/// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
/// sell copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
/// KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
/// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
/// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
/// OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
/// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
/// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
/// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import MultipeerConnectivity
import RealityKit

/// - Tag: MultipeerSession
class MultipeerSession: NSObject {
  static let serviceType = "ar-collab"
  
  private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
  private var session: MCSession!
  private var serviceAdvertiser: MCNearbyServiceAdvertiser!
  private var serviceBrowser: MCNearbyServiceBrowser!
  
  private let receivedDataHandler: (Data, MCPeerID) -> Void
  private let peerJoinedHandler: (MCPeerID) -> Void
  private let peerLeftHandler: (MCPeerID) -> Void
  private let peerDiscoveredHandler: (MCPeerID) -> Bool
  
  /// - Tag: MultipeerSetup
  init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void,
       peerJoinedHandler: @escaping (MCPeerID) -> Void,
       peerLeftHandler: @escaping (MCPeerID) -> Void,
       peerDiscoveredHandler: @escaping (MCPeerID) -> Bool) {
    self.receivedDataHandler = receivedDataHandler
    self.peerJoinedHandler = peerJoinedHandler
    self.peerLeftHandler = peerLeftHandler
    self.peerDiscoveredHandler = peerDiscoveredHandler
    
    super.init()
    
    session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
    session.delegate = self
    
    serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerSession.serviceType)
    serviceAdvertiser.delegate = self
    serviceAdvertiser.startAdvertisingPeer()
    
    serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerSession.serviceType)
    serviceBrowser.delegate = self
    serviceBrowser.startBrowsingForPeers()
  }
  
  func sendToAllPeers(_ data: Data, reliably: Bool) {
    sendToPeers(data, reliably: reliably, peers: connectedPeers)
  }
  
  /// - Tag: SendToPeers
  func sendToPeers(_ data: Data, reliably: Bool, peers: [MCPeerID]) {
    guard !peers.isEmpty else { return }
    do {
      try session.send(data, toPeers: peers, with: reliably ? .reliable : .unreliable)
    } catch {
      print("error sending data to peers \(peers): \(error.localizedDescription)")
    }
  }
  
  var connectedPeers: [MCPeerID] {
    return session.connectedPeers
  }
}

extension MultipeerSession: MCSessionDelegate {
  
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    if state == .connected {
      peerJoinedHandler(peerID)
    } else if state == .notConnected {
      peerLeftHandler(peerID)
    }
  }
  
  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    receivedDataHandler(data, peerID)
  }
  
  func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
               fromPeer peerID: MCPeerID) {
    fatalError("This service does not send/receive streams.")
  }
  
  func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
               fromPeer peerID: MCPeerID, with progress: Progress) {
    fatalError("This service does not send/receive resources.")
  }
  
  func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
               fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    fatalError("This service does not send/receive resources.")
  }
}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
  
  /// - Tag: FoundPeer
  public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
    // Ask the handler whether we should invite this peer or not
    let accepted = peerDiscoveredHandler(peerID)
    if accepted {
      browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
  }
  
  public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    // This app doesn't do anything with non-invited peers, so there's nothing to do here.
  }
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
  
  /// - Tag: AcceptInvite
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                  withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    // Call the handler to accept the peer's invitation to join.
    invitationHandler(true, self.session)
  }
}

extension MultipeerSession {
  public var multipeerConnectivityService: MultipeerConnectivityService? {
    return try? MultipeerConnectivityService(session: self.session)
  }
}
