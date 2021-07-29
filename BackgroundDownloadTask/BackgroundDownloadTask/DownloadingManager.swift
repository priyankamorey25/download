//
//  DownloadingManager.swift
//  BackgroundDownloadTask
//
//  Created by Priyanka Morey on 25/07/21.
//

import Foundation
import UIKit
import UserNotifications

final public class DownloadManager: NSObject {
    
    public typealias DownloadCompletionBlock = (_ error : Error?, _ fileUrl:URL?) -> Void
    public typealias DownloadProgressBlock = (_ progress : CGFloat) -> Void
    public typealias BackgroundDownloadCompletionHandler = () -> Void
    
    private var session: URLSession!
    private var ongoingDownloads: [String : DownloadObject] = [:]
    var backgroundSession: URLSession!
    
    public var backgroundCompletionHandler: BackgroundDownloadCompletionHandler?
   public static let shared: DownloadManager = { return DownloadManager() }()

    //MARK:- Public methods
    
    public func downloadFile(withRequest request: URLRequest,
                            inDirectory directory: String? = nil,
                            withName fileName: String? = nil,
                            shouldDownloadInBackground: Bool = false,
                            onProgress progressBlock:DownloadProgressBlock? = nil,
                            onCompletion completionBlock:@escaping DownloadCompletionBlock) -> String? {
    
        guard let url = request.url else {
            debugPrint("Request url is empty")
            return nil
        }
        
        if let _ = self.ongoingDownloads[url.absoluteString] {
            debugPrint("Already in progress")
            return nil
        }
        var downloadTask: URLSessionDownloadTask
        if shouldDownloadInBackground {
            downloadTask = self.backgroundSession.downloadTask(with: request)
        } else{
            downloadTask = self.session.downloadTask(with: request)
        }
        
        let download = DownloadObject(downloadTask: downloadTask,
                                        progressBlock: progressBlock,
                                        completionBlock: completionBlock,
                                        fileName: fileName,
                                        directoryName: directory)

        let key = self.getDownloadKey(withUrl: url)
        self.ongoingDownloads[key] = download
        downloadTask.resume()
        return key
    }
    
    public func getDownloadKey(withUrl url: URL) -> String {
        return url.absoluteString
    }
    
    public func currentDownloads() -> [String] {
        return Array(self.ongoingDownloads.keys)
    }
    
     func getdownloadprogress() -> [String: DownloadObject]?
    {
        return self.ongoingDownloads
    }
    
    public func cancelAllDownloads() {
        for (_, download) in self.ongoingDownloads {
            let downloadTask = download.downloadTask
            downloadTask.cancel()
        }
        self.ongoingDownloads.removeAll()
    }
    
    public func cancelDownload(forUniqueKey key:String?) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                download.downloadTask.cancel()
                self.ongoingDownloads.removeValue(forKey: key!)
            }
        }
    }
    
    public func pause(forUniqueKey key:String?) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                let downloadTask = download.downloadTask
                downloadTask.suspend()
            }}
    }
    
    public func resume(forUniqueKey key:String?) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                let downloadTask = download.downloadTask
                downloadTask.resume()
            }}
    }
    
    public func isDownloadInProgress(forKey key:String?) -> Bool {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        return downloadStatus.0
    }
    
    //MARK:- Private methods
    
    private override init() {
        super.init()
        let sessionConfiguration = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier!)
        self.backgroundSession = URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: OperationQueue())
    }

    private func isDownloadInProgress(forUniqueKey key:String?) -> (Bool, DownloadObject?) {
        guard let key = key else { return (false, nil) }
        for (uniqueKey, download) in self.ongoingDownloads {
            if key == uniqueKey {
                return (true, download)
            }
        }
        return (false, nil)
    }
    
    private func calculateProgress(session : URLSession, completionHandler : @escaping DownloadProgressBlock) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let progress = downloads.map({ (task) -> CGFloat in
                if task.countOfBytesExpectedToReceive > 0 {
                    return CGFloat(task.countOfBytesReceived) / CGFloat(task.countOfBytesExpectedToReceive)
                } else {
                    return 0.0
                }
            })

            OperationQueue.main.addOperation({
             completionHandler(progress.reduce(0.0, +))
            })
        }
    }
    
   //Uplaod task
    
    func sendPostRequest(to url: URL,body: Data,handler: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        
        request.httpMethod = "POST"
        
        let task = backgroundSession.uploadTask(
            with: request,
            from: body,
            completionHandler: { data, response, error in
                print(response)
            }
        )
        task.resume()
    }
    
    func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
        {
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

            let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

            if FileManager().fileExists(atPath: destinationUrl.path)
            {
                print("File already exists [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else if let dataFromURL = NSData(contentsOf: url)
            {
                if dataFromURL.write(to: destinationUrl, atomically: true)
                {
                    print("file saved [\(destinationUrl.path)]")
                    completion(destinationUrl.path, nil)
                }
                else
                {
                    print("error saving file")
                    let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                    completion(destinationUrl.path, error)
                }
            }
            else
            {
                let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
    
}

extension DownloadManager : URLSessionDelegate, URLSessionDownloadDelegate {
    
    // MARK:- Delegates
    
    public func urlSession(_ session: URLSession,
                             downloadTask: URLSessionDownloadTask,
                             didFinishDownloadingTo location: URL) {
        
        let key = (downloadTask.originalRequest?.url?.absoluteString)!
        if let download = self.ongoingDownloads[key]  {
            if let response = downloadTask.response {
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                guard statusCode < 400 else {
                    let error = NSError(domain:"HttpError", code:statusCode, userInfo:[NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: statusCode)])
                    OperationQueue.main.addOperation({
                        download.completionBlock(error,nil)
                    })
                    return
                }
                let fileName = download.fileName ?? downloadTask.response?.suggestedFilename ?? (downloadTask.originalRequest?.url?.lastPathComponent)!
                let directoryName = download.directoryName
//                self.loadFileSync(url: location) { (path, error) in
//                    print("PDF File downloaded to : \(path!)")
//                }
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                let destinationUrl = documentsUrl.appendingPathComponent(downloadTask.originalRequest?.url?.lastPathComponent ?? "")

                        if FileManager().fileExists(atPath: destinationUrl.path)
                        {
                            print("File already exists [\(destinationUrl.path)]")
                            //completion(destinationUrl.path, nil)
                        }
                        else if let dataFromURL = NSData(contentsOf: downloadTask.originalRequest?.url ?? NSURL(string: "") as! URL)
                        {
                            if dataFromURL.write(to: destinationUrl, atomically: true)
                            {
                                print("file saved [\(destinationUrl.path)]")
                               // completion(destinationUrl.path, nil)
                            }
                            else
                            {
                                print("error saving file")
                                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                               // completion(destinationUrl.path, error)
                            }
                        }
                        else
                        {
                            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
                           // completion(destinationUrl.path, error)
                        }
                let fileMovingResult = DownloadHelper.moveFile(fromUrl: location, toDirectory: directoryName, withName: fileName)
                let didSucceed = fileMovingResult.0
                let error = fileMovingResult.1
                let finalFileUrl = fileMovingResult.2
                
                OperationQueue.main.addOperation({
                    (didSucceed ? download.completionBlock(nil,finalFileUrl) : download.completionBlock(error,nil))
                })
            }
        }
        self.ongoingDownloads.removeValue(forKey:key)
    }
    
    
    public func urlSession(_ session: URLSession,
                             downloadTask: URLSessionDownloadTask,
                             didWriteData bytesWritten: Int64,
                             totalBytesWritten: Int64,
                             totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else {
            debugPrint("Could not calculate progress as totalBytesExpectedToWrite is less than 0")
            return;
        }
        
        if let download = self.ongoingDownloads[(downloadTask.originalRequest?.url?.absoluteString)!],
            let progressBlock = download.progressBlock {
            calculateProgress(session: session, completionHandler: progressBlock)
           // let progress : CGFloat = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
            OperationQueue.main.addOperation({
            // progressBlock(progress)
            })
        }
    }
    
    public func urlSession(_ session: URLSession,
                             task: URLSessionTask,
                             didCompleteWithError error: Error?) {
        
        if let error = error {
            let downloadTask = task as! URLSessionDownloadTask
            let key = (downloadTask.originalRequest?.url?.absoluteString)!
            if let download = self.ongoingDownloads[key] {
                OperationQueue.main.addOperation({
                    download.completionBlock(error,nil)
                })
            }
            self.ongoingDownloads.removeValue(forKey:key)
        }
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if downloadTasks.count == 0 {
                DispatchQueue.main.async {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                       let completionHandler = appDelegate.backgroundCompletionHandler {
                        appDelegate.backgroundCompletionHandler = nil
                        completionHandler()
                    }
                }
            }
        }
    }
}
