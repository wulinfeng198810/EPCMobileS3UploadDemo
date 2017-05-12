//
//  EPCUploadListCell.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 10/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit

class EPCUploadListCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: EPCPhotoDBModelProtocol?
    
    var model:EPCPhotoDBModel? {
        
        didSet{
            
//            var image = UIImage(contentsOfFile: model?.filePath ?? "")
//            image = image?.epc_scaleImage(size: imgView.bounds.size)
//            imgView.image = image
            
            imgView.image = UIImage(contentsOfFile: model?.filePath ?? "")
            
            
            if model?.transferState == .EPCPhotoUploadState_running {
                progressView.isHidden = false
                cancelButton.isHidden = false
                progressAction()
            }
            else if model?.transferState == .EPCPhotoUploadState_success {
                successAction()
            }
            else if model?.transferState == .EPCPhotoUploadState_failed {
                failedAction()
            }
            
            model?.progressBlock = { (persent) in
                self.progressAction()
            }
            
            model?.completionHandler = { (success, error) in
                success ? self.successAction() : self.failedAction()
            }
        }
    }

    private func progressAction() {
        var lastPersent = Float(model?.totalBytesSent ?? 0)/Float(model?.totalBytesExpectedToSend ?? 1)
        lastPersent = lastPersent > 1 ? 1 : lastPersent
        
        let str = String(format: "%.1f%%", lastPersent * 100)
        debugPrint(str)
        self.progressView.progress = Float(lastPersent)
        self.progressLabel.text = String(format: "%.1f%%", lastPersent * 100)
    }
    
    private func successAction() {
        self.progressView.isHidden = true
        self.progressView.progress = Float(1)
        self.progressLabel.text = "Done"
        
        cancelButton.isHidden = true
    }
    
    private func failedAction() {
        self.progressView.isHidden = true
        let lastPersent = Float(model?.totalBytesSent ?? 0)/Float(model?.totalBytesExpectedToSend ?? 1)
        self.progressView.progress = Float(lastPersent)
        
        self.progressLabel.text = "Faild"
        cancelButton.isHidden = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func pause(_ sender: Any) {
        
        if let photoModel = model {
            delegate?.EPCPhotoDBModelChangeState(photoModel: photoModel)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
