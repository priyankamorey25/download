////
////  NetworkManager.swift
////  BackgroundDownloadTask
////
////  Created by Priyanka Morey on 18/07/21.
////
//
//import Foundation
//import UIKit
//
//extension URLSession {
//    func getSessionDescription () -> Int {
//        // row id
//        return Int(self.sessionDescription!)!
//    }
//    
//    func getDebugDescription () -> Int {
//        // table id
//        return Int(self.debugDescription)!
//    }
//}
//
//class NetworkManager : NSObject
//{
//    static let instance = NetworkManager()
//    var downloadTask: URLSessionDownloadTask!
//    var pdfURL : URL!
//    var progress: Float?
//    var isDownloading = false
//    var resumeData: Data?
//    var identifier : Int = -1
//    
//     lazy var downloadSession: URLSession = {
//        let config = URLSessionConfiguration.background(withIdentifier: "com.priyanka.BackgroundDownloadTask")
//        config.isDiscretionary = true
//        config.sessionSendsLaunchEvents = true
//       
//        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
//    }()
//   
//    typealias ProgressHandler = (Int,Float) -> ()
//   
//    typealias CompletionHandler = (_ success:Bool, _ dataURL:URL) -> Void
//    var onProgress : ProgressHandler? {
//        didSet {
//            if onProgress != nil {
//                let _ = downloadSession
//            }
//        }
//    }
//    override init()
//    {
//        super.init()
//        
//    }
//    func activate() -> URLSession {
//        let config = URLSessionConfiguration.background(withIdentifier: "com.priyanka.BackgroundDownloadTask")
//        config.isDiscretionary = true
//        config.sessionSendsLaunchEvents = true
//        downloadSession.sessionDescription = String(identifier)
//        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
//    }
//    
//    func download(_ url : URL, completion: @escaping (_ success: Bool) -> ())
//    {
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        downloadTask = activate().downloadTask(with: urlRequest)
//        downloadTask.resume()
//        isDownloading = true
//        completion(true)
//    }
//    
//    
//    func cancel() {
//        downloadTask.cancel()
//    }
//    
////    func downloadFileFromURL(url: URL, completion: @escaping (_ success:Bool, _ data : URL, _ progress: Float) -> Void)  {
////        download(url){
////            print("completed")
////        }
////        completion(true, pdfURL,progress ?? 0.0)
////    }
//    
//    private func calculateProgress(session : URLSession, completionHandler : @escaping (Int, Float) -> ()) {
//        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
//            let progress = downloads.map({ (task) -> Float in
//                if task.countOfBytesExpectedToReceive > 0 {
//                    
//                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
//                } else {
//                    return 0.0
//                }
//            })
//            
//            completionHandler(session.getSessionDescription(), progress.reduce(0.0, +))
//          //  completionHandler(session.getSessionDescription(), progress.reduce(0.0, +))
//        }
//    }
//}
//
//
//extension NetworkManager: URLSessionDownloadDelegate, URLSessionDelegate
//{
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        if totalBytesExpectedToWrite > 0 {
//            if let onProgresss = onProgress {
//                calculateProgress(session: session, completionHandler: onProgresss)
//            }
//            let recentProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//            progress = recentProgress
//            print("\(progress)")
//        }
//    }
//    
//    func urlSession(_ session: URLSession,
//                    downloadTask: URLSessionDownloadTask,
//                    didFinishDownloadingTo location: URL)
//    {
//        print("File Downloaded Location- ",  location)
//        
//        guard let url = downloadTask.originalRequest?.url else {
//            return
//        }
//        let docsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
//        let destinationPath = docsPath.appendingPathComponent(url.lastPathComponent)
//        
//        try? FileManager.default.removeItem(at: destinationPath)
//        
//        do{
//            try FileManager.default.copyItem(at: location, to: destinationPath)
//            pdfURL = destinationPath
//            print("File Downloaded Location- ",  pdfURL ?? "NOT")
//        }catch let error {
//            print("Copy Error: \(error.localizedDescription)")
//        }
//    }
//    
//    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        DispatchQueue.main.async {
//            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
//               let completionHandler = appDelegate.backgroundCompletionHandler {
//                appDelegate.backgroundCompletionHandler = nil
//                completionHandler()
//            }
//        }
//    }
//}
