//
//  DownloadViewController.swift
//  BackgroundDownloadTask
//
//  Created by Priyanka Morey on 25/07/21.
//

import UIKit

class DownloadViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var itemDownload = [Downlaod] ()
    private let downloadManager = DownloadManager.shared
    let directoryName : String = "TestDirectory"
    var ongoingProg =  Float()
    let fiveMBUrl = "https://sample-videos.com/video123/mp4/480/big_buck_bunny_480p_5mb.mp4"
    let tenMBUrl = "https://sample-videos.com/video123/mp4/480/big_buck_bunny_480p_10mb.mp4"
    let normMBUrl = "https://www.rmp-streaming.com/media/big-buck-bunny-360p.mp4"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemDownload.append(Downlaod(title:"File 1", link: fiveMBUrl))
        itemDownload.append(Downlaod(title:"File 2", link: tenMBUrl))
        itemDownload.append(Downlaod(title:"File 3", link: normMBUrl))
       }
    
    private func backgroundDownload(urlString:String, downloadViewCell: DownloadViewCell) {
        let request = URLRequest(url: URL(string: urlString)!)
        let downloadKey = self.downloadManager.downloadFile(withRequest: request, inDirectory: directoryName, withName: directoryName, shouldDownloadInBackground: true, onProgress: { (progress) in
           // let percentage = String(format: "%.1f %", (progress * 100))
            debugPrint("Background progress : \(progress * 100)")
            DispatchQueue.main.async {
                downloadViewCell.circularProgress.progress = progress
            }
           }) { [weak self] (error, url) in
            if let error = error {
                print("Error is \(error as NSError)")
            } else {
                if let url = url {
                    print("Downloaded file's url is \(url.path)")
                    print("download complete")
                   // self?.finalUrlLabel.text = url.path
                }
            }
        }
        
        print("The key is \(String(describing: downloadKey))")
    }
    
    @IBAction func multipleDownload(_ sender: Any) {
        
    
    }
    
}

extension DownloadViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDownload.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadViewCell", for: indexPath) as! DownloadViewCell
        cell.titleLbl.text = itemDownload[indexPath.row].title
        cell.downloadBtn.addTarget(self, action: #selector(downloadClicked(sender:)), for: .touchUpInside)
        cell.CancelBtn.addTarget(self, action: #selector(cancelClick(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func downloadClicked(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at:buttonPosition) {
            let cell = tableView.cellForRow(at: indexPath) as? DownloadViewCell
            backgroundDownload(urlString: itemDownload[indexPath.row].link, downloadViewCell: cell!)
        }
    }
    
    @objc func cancelClick(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at:buttonPosition) {
           // let cell = tableView.cellForRow(at: indexPath) as? DownloadViewCell
            downloadManager.cancelDownload(forUniqueKey: itemDownload[indexPath.row].link)
           // cell?.circularProgress.progress = CGFloat(ongoingProg)
        }
    }

}

struct Downlaod {
    let title : String
    let DownloadStatus:DownloadStatus = .none
    let link : String
    
    init(title:String, link: String) {
        self.title = title
        self.link = link
    }
}

enum DownloadStatus {
    case none
    case inProgress
    case completed
    case failed
}
