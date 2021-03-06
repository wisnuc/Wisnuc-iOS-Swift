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
    var online: Int?
    var onlineTime : String?
    var offlineTime : String?
    var LANIP:String?
    var name:String?
    var isShareStation:Bool?
    var bootSpace:BootSpaceModel?
    
    
    enum CodingKeys : String, CodingKey {
        case sn
        case createdAt
        case owner
        case online
        case onlineTime
        case offlineTime
        case LANIP
        case name
    }
}
