//
//  DownloadProgressViewController.swift
//  BackgroundDownloadTask
//
//  Created by Priyanka Morey on 25/07/21.
//

import UIKit

class DownloadProgressViewController: UIViewController {
    
    @IBOutlet weak var progressView: ProgressBar!
    var downloadManager = DownloadManager.shared
    var downloadData : [String:DownloadObject] = [:]
    var downloadKey : [String] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadKey = downloadManager.currentDownloads()
        downloadData = downloadManager.getdownloadprogress() ?? [:]
    }
}

extension DownloadProgressViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadViewCell", for: indexPath) as! DownloadViewCell
        DispatchQueue.main.async {
            cell.titleLbl.text = self.downloadData[self.downloadKey[indexPath.row]]?.fileName
          //  let downloadStatus = self.downloadManager.isDownloadInProgress(forKey: self.downloadKey[indexPath.row])
            
            //if self.downloadManager.isDownloadInProgress(forKey: self.downloadKey[indexPath.row] {
            self.downloadData[self.downloadKey[indexPath.row]]?.progressBlock = {
            (progress) in
            print( "current Progress",indexPath.row, progress * 100)
            cell.circularProgress.progress = progress
            }
            //}
        }
        
        cell.downloadBtn.addTarget(self, action: #selector(downloadClicked(sender:)), for: .touchUpInside)
        cell.CancelBtn.addTarget(self, action: #selector(cancelClick(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func downloadClicked(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at:buttonPosition) {
            let cell = tableView.cellForRow(at: indexPath) as? DownloadViewCell
           // backgroundDownload(urlString: itemDownload[indexPath.row].link, downloadViewCell: cell!)
           // cell?.circularProgress.progress = CGFloat(ongoingProg)
        }
    }
    
    @objc func cancelClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at:buttonPosition) {
            let cell = tableView.cellForRow(at: indexPath) as? DownloadViewCell
            downloadManager.cancelDownload(forUniqueKey: downloadKey[indexPath.row])
         //  dismiss(animated: true, completion: nil)
        }
    }
}


extension String {
  func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
}
