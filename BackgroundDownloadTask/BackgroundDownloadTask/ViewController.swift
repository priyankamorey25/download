////
////  ViewController.swift
////  BackgroundDownloadTask
////
////  Created by Priyanka Morey on 16/07/21.
////
//
//import UIKit
//import AVKit
//class ViewController: UIViewController,URLSessionTaskDelegate {
//
//    @IBOutlet weak var dataView: UIView!
//
//    @IBOutlet weak var downloadBtn: UIButton!
//    @IBOutlet weak var pauseBtn: UIButton!
//    @IBOutlet weak var progressbar: UIProgressView!
//    let downloadManager = NetworkManager.instance
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//// func donloadFilefromdownloadTask(_ url: URL) {
////        NetworkManager.instance.downloadFileFromURL(url: url, completion: { [weak self] (success,result, progress)   in
////            if success {
////                print(progress)
////                self?.progressbar.progress = progress
////                self?.playVideo(filepathURL: result)
////            }
////        })
////    }
//
//
//
//    @IBAction func downloadAction(_ sender: Any) {
//       if let dataURL =  URL(string: "https://www.rmp-streaming.com/media/big-buck-bunny-360p.mp4") {
//
//            NetworkManager.instance.download(dataURL, completion: {(success) in
//                if success {
//
//                }
//                self.downloadManager.onProgress = { progressData,progress in
//                   if progress <= 1.0 {
//                       DispatchQueue.main.async {
//                        print(progressData)
//                       self.progressbar.progress = progress
//                       }
//                   }
//
//               }
//            })
//
//        }
//
////        if let dataURL = URL(string: "https://www.rmp-streaming.com/media/big-buck-bunny-360p.mp4") {
////        donloadFilefromdownloadTask(dataURL)
////        }
////
////        downloadManager.onProgress = { progress in
////           if progress <= 1.0 {
////               DispatchQueue.main.async {
////               self.progressbar.progress = progress
////               }
////           }
////
////       }
//    }
//
//
//    @IBAction func cancelAction(_ sender: Any) {
//        downloadManager.cancel()
//  }
//
//    func playVideo(filepathURL: URL)  {
//        let player = AVPlayer(url: filepathURL)
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = self.dataView.bounds
//        playerLayer.player = player
//        playerLayer.videoGravity = .resizeAspectFill
//        self.dataView.layer.addSublayer(playerLayer)
//        DispatchQueue.main.async {
//            playerLayer.player?.play()
//        }
//    }
//}
