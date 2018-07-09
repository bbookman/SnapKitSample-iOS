//
//  ViewController.swift
//  SnapClient
//
//  Created by Kei Fujikawa on 2018/06/15.
//  Copyright © 2018年 Kboy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SCSDKCreativeKit
import SCSDKBitmojiKit

class CameraViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var iconView: UIImageView! {
        didSet {
            iconView.backgroundColor = .white
            iconView.layer.cornerRadius = iconView.frame.width/2
            iconView.clipsToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneView.scene = scene
        
        // fetch your avatar image.
        SCSDKBitmojiClient.fetchAvatarURL { (avatarURL: String?, error: Error?) in
            DispatchQueue.main.async {
                if let avatarURL = avatarURL {
                    self.iconView.load(from: avatarURL)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction func snapButtonTapped(_ sender: Any) {
        let snapshot = sceneView.snapshot()
        let photo = SCSDKSnapPhoto(image: snapshot)
        let snap = SCSDKPhotoSnapContent(snapPhoto: photo)
        
        // Sticker
        let sticker = SCSDKSnapSticker(stickerImage: #imageLiteral(resourceName: "snap-ghost"))
        snap.sticker = sticker
        
        // Caption
        snap.caption = "Snap on Snapchat!"
        
        // URL
        snap.attachmentUrl = "https://www.snapchat.com"
        
        let api = SCSDKSnapAPI(content: snap)
        api.startSnapping { error in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                // success
            }
        }
    }
}
