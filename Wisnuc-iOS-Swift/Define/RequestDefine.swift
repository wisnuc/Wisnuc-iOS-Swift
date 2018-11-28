//
//  RequestDefine.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
public let KWxAppID = "wx99b54eb728323fe8"
//public let kCloudAddr = "http://www.siyouqun.com"
//public let kCloudAddr = "https://abel.nodetribe.com"
//public let kCloudBaseURL = "https://abel.nodetribe.com/c/v1"
public let kCloudAddr = "https://test.nodetribe.com"
public let kCloudBaseURL = "https://test.nodetribe.com/c/v1"
//public let kCloudBaseURL = "http://www.siyouqun.com/c/v1"

//#define kCloudAddr    @"http://10.10.9.87:4000/"
//#define WX_BASE_URL   @"http://10.10.9.87:4000/c/v1/"
//public let kDevelopAddr = "http://abel.nodetribe.com/c/v1"

public let kCloudCommonJsonUrl = "/station/\(String(describing: AppUserService.currentUser?.stationId ?? ""))/json"
public let kCloudCommonPipeUrl = "/station/\(String(describing: AppUserService.currentUser?.stationId ?? ""))/pipe"
public let kRquestDrivesURL = "drives"
public let kRequestMkdirValue = "mkdir"
public let kRequestEntriesValueKey = "entries"
public let kBackUpAssetDirName  = "上传的照片"

public let kRequestAuthorizationKey = "Authorization"
public let kRequestSetCookieKey = "cookie"
//public let kRequestMethodKey = "method"
//public let kRequestResourceKey = "resource"
public let kRequestOpKey       = "op"
public let kRequestToNameKey  =  "toName"
public let kRequestFromNameKey  = "fromName"

public let kRequestUrlPathKey = "urlPath"
public let kRequestVerbKey = "verb"

public let kRequestOpNewFileValue    = "newfile"

public let kRequestTaskTypeKey = "type"
public let kRequestTaskDriveKey = "drive"
public let kRequestTaskDirKey = "dir"
public let kRequestTaskSrcKey = "src"
public let kRequestTaskDstKey = "dst"
public let kRequestTaskPolicyKey = "policy"

public let kRequestImageAltKey = "alt"
public let kRequestImageWidthKey = "width"
public let kRequestImageHeightKey = "height"
public let kRequestImageModifierKey = "modifier"
public let kRequestImageAutoOrientKey = "autoOrient"

public let kRequestImageCaretValue = "caret"
public let kRequestImageThumbnailValue = "thumbnail"
public let kRequestImageDataValue = "data"
public let kRequestImageRandomValue = "random"
public let kRequestImageParamsKey = "params"

public let kRequestClassKey = "class"
public let kRequestPlacesKey = "places"

public let kRequestBodyKey = "body"

public let kRequestContentTypeKey = "Content-Type"
public let kRequestContentTypeJsonValue = "application/json"

public let kHTTPTCPSearchBrowerType = "_http._tcp"

public let kRequestWechatKey = "wechat"

public let kRequestResponseMessageKey = "message"



