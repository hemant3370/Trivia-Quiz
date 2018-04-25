//
//  DiscoveryViewController.swift
//  Quiz
//
//  Created by Hemant Singh on 18/04/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DiscoveryViewController: UIViewController {
    var quizManager: QuizManager?
    var questions: [Question] = [Question]()
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    var otherPeerId: MCPeerID?
    var otherScore: (Int, Int)?
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        if questions.count == 0 {
            joinSession()
        }
        else{
            startHosting()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if let manager = self.quizManager, let otherPlayer = otherPeerId {
            self.questions = manager.questions
            let score: Int = manager.score().0
            let data = Data(from: score)
            try? self.mcSession.send(data, toPeers: [otherPlayer], with: .reliable)
            if let score = otherScore {
                self.performSegue(withIdentifier: "toResult", sender: score)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startHosting() {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
    
    @IBAction func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "playQuiz", let dest = segue.destination as? QuizViewController {
            dest.questions = self.questions
        }
        if segue.identifier == "toResult", let dest = segue.destination as? ResultViewController, let score = sender as? (Int, Int), let manager = quizManager {
            dest.quizManager = manager
            dest.otherScore = score
        }
    }
    
}
extension DiscoveryViewController: MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            otherPeerId = peerID
            dismiss(animated: true)
            if questions.count > 0 {
                questions.forEach({[weak self] (question) in
                    if let data = try? question.jsonData() {
                    try? self?.mcSession.send(data, toPeers: [peerID], with: .reliable)
                    }
                })
                self.performSegue(withIdentifier: "playQuiz", sender: nil)
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let question = try? Question.init(data: data) {
            questions.append(question)
            if questions.count == 10 {
                self.performSegue(withIdentifier: "playQuiz", sender: nil)
            }
        }
        else {
            otherScore = (data.to(type: Int.self), 10)
            if let _ = quizManager {
            self.performSegue(withIdentifier: "toResult", sender: otherScore)
            }
        }
    }
}
extension Data {
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}
