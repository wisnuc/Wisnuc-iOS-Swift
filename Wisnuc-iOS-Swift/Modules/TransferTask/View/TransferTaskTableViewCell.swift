//
//  TransferTaskTableViewCell.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialProgressView
import MDRadialProgress

enum TransferTaskTableViewCellType {
    case task
    case model
}

class TransferTaskTableViewCell: UITableViewCell {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var progress: MDRadialProgressView!
    @IBOutlet weak var suspendButton: UIButton!
    var task:TRTask?
    var model:FilesTasksModel?
    var type:TransferTaskTableViewCellType?
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = DarkGrayColor
        detailLabel.textColor = LightGrayColor
        controlButton.isUserInteractionEnabled = false
        controlButton.tintColor = LightGrayColor
        suspendButton.tintColor = DarkGrayColor
       
        progress.theme.sliceDividerHidden = true
        progress.label.textColor = LightGrayColor
        progress.label.font = UIFont.systemFont(ofSize: 10)
        progress.theme.thickness = 10
        progress.theme.completedColor = COR1
        progress.theme.incompletedColor = COR1.withAlphaComponent(0.12)
        progress.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setModel(model:FilesTasksModel){
        self.model = model
        self.type = .model
        self.progress.isHidden = true
    }
    
    func setTask(task:TRTask){
        self.task = task
        self.type = .task
    }
    
    func updateProgress(task: TRTask) {
        switch task.status {
        case .running:
            progress.isHidden = false
        case .completed:
            progress.isHidden = true
            self.controlButton.setImage(#imageLiteral(resourceName: "file_finish.png"), for: .normal)
        case .failed:
            self.controlButton.setImage(UIImage.init(named: "files_error.png"), for: .normal)
        case .suspend,.preSuspend:
            progress.theme.completedColor = UIColor.black.withAlphaComponent(0.54)
            progress.theme.incompletedColor = UIColor.black.withAlphaComponent(0.12)
            progress.label.isHidden = true
            suspendButton.isHidden = false
        default:
            progress.isHidden = true
            progress.theme.completedColor = COR1
            progress.theme.incompletedColor = COR1.withAlphaComponent(0.12)
            progress.label.isHidden = false
            suspendButton.isHidden = true
        }
    }

    @IBAction func suspendButtonTap(_ sender: UIButton) {
    }
    @IBOutlet weak var controlButtonTap: UIButton!
}
