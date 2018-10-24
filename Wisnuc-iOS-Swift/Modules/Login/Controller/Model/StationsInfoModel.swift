//
//  StationModel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/23.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

struct StationsInfoModel: Decodable {
    var sn:String?
    var createdAt:String?
    var owner:String?
    var online: Bool?
    var onlineTime : String?
    var offlineTime : String?
}
