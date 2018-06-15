//
//  TransferTaskTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialProgressView

class TransferTaskTableViewCell: UITableViewCell {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var progress: MDCProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        detailLabel.textColor = LightGrayColor
        controlButton.isUserInteractionEnabled = false
        controlButton.tintColor = LightGrayColor
        progress.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func updateProgress(task: TRTask) {
        detailLabel.text = "\(task.progress.completedUnitCount.tr.convertBytesToString())"
//        progressView.progress = Float(task.progress.fractionCompleted)
//        bytesLabel.text = "\(task.progress.completedUnitCount.tr.convertBytesToString())/\(task.progress.totalUnitCount.tr.convertBytesToString())"
//        speedLabel.text = task.speed.tr.convertSpeedToString()
//        timeRemainingLabel.text = "剩余时间：\(task.timeRemaining.tr.convertTimeToString())"
//        startDateLabel.text = "开始时间：\(task.startDate.tr.convertTimeToDateString())"
//        endDateLabel.text = "结束时间：\(task.endDate.tr.convertTimeToDateString())"
        
    }

    
    @IBOutlet weak var controlButtonTap: UIButton!
}
