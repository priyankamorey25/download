//
//  DownloadViewCell.swift
//  BackgroundDownloadTask
//
//  Created by Priyanka Morey on 25/07/21.
//

import UIKit
protocol DownLoadTableViewCellDelegate: class {
    
    func downloadCompleted()
    func downloadFailedWithError(message:String)
}
class DownloadViewCell: UITableViewCell {

    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var circularProgress: ProgressBar!
    weak var cellDelegate:DownLoadTableViewCellDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
    
        // Initialization code
    }
    func updateProgress(progress: Float) {
        circularProgress.progress = CGFloat(progress)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
}
