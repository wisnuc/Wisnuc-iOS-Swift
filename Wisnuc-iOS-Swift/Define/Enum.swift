
//
//  Enum.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

enum FilesType:String{
    case file = "file"
    case directory = "directory"
}

public let kVideoTypes:Array<String> = [FilesFormatType.MP4.rawValue,FilesFormatType.RMVB.rawValue,FilesFormatType.RM.rawValue,FilesFormatType.AVI.rawValue,FilesFormatType.MKV.rawValue,FilesFormatType.WMV.rawValue,FilesFormatType.SWF.rawValue,FilesFormatType.FLV.rawValue,FilesFormatType.MOV.rawValue]

public let kImageTypes:Array<String> = [FilesFormatType.PNG.rawValue,FilesFormatType.JPG.rawValue,FilesFormatType.JPEG.rawValue,FilesFormatType.GIF.rawValue]
public let kMediaTypes:Array<String> = {
   var array = Array<String>.init()
    array.append(contentsOf: kImageTypes)
    array.append(contentsOf: kVideoTypes)
    return array
}()
//[FilesFormatType.PNG.rawValue,FilesFormatType.JPG.rawValue,FilesFormatType.JPEG.rawValue,FilesFormatType.GIF.rawValue]

enum FilesFormatType:String {

    case EXE = "exe"
    case PDF = "pdf"
    case PNG = "png"
    case JPG = "jpg"
    case JPEG = "jpeg"
    case GIF = "gif"
    case MP4 = "mp4"
    case RMVB = "rmvb"
    case RM = "rm"
    case AVI = "avi"
    case MKV = "mkv"
    case WMV = "wmv"
    case SWF = "swf"
    case FLV = "flv"
    case MOV = "mov"
    case MP3 = "mp3"
    case AAC = "aac"
    case WAV = "wav"
    case FLAC = "flac"
    case APE = "ape"
    case TXT = "txt"
    case PPT = "ppt"
    case PPTX = "pptx"
    case DOC = "doc"
    case DOCX = "docx"
    case XLS = "xls"
    case XLSX = "xlsx"
    case DEFAULT
}
