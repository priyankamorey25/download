//
//  DownloadObject.swift
//  BackgroundDownloadTask
//
//  Created by Priyanka Morey on 25/07/21.
//

import Foundation
import UIKit

class DownloadObject: NSObject {

    var completionBlock: DownloadManager.DownloadCompletionBlock
    var progressBlock : DownloadManager.DownloadProgressBlock? {
        didSet {
            if progressBlock != nil {
                let _ = DownloadManager.shared.backgroundSession
                
            }
        }
    }
    let downloadTask: URLSessionDownloadTask
    let directoryName: String?
    let fileName:String?
    
   

    
    init(downloadTask: URLSessionDownloadTask,
         progressBlock:  DownloadManager.DownloadProgressBlock?,
         completionBlock: @escaping DownloadManager.DownloadCompletionBlock,
         fileName: String?,
         directoryName: String?) {
        
        self.downloadTask = downloadTask
        self.completionBlock = completionBlock
        self.progressBlock = progressBlock
        self.fileName = fileName
        self.directoryName = directoryName
    }
    
}
