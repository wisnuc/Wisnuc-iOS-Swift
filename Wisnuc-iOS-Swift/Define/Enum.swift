
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

public let kVideoTypes:Array<String> = [FilesFormatType.MP4.rawValue,FilesFormatType.RMVB.rawValue,FilesFormatType.RM.rawValue,FilesFormatType.AVI.rawValue,FilesFormatType.MKV.rawValue,FilesFormatType.WMV.rawValue,FilesFormatType.SWF.rawValue,FilesFormatType.FLV.rawValue,FilesFormatType.MOV.rawValue,FilesFormatType.ThreeGP.rawValue]

public let kImageTypes:Array<String> = [FilesFormatType.PNG.rawValue,FilesFormatType.JPG.rawValue,FilesFormatType.JPEG.rawValue,FilesFormatType.GIF.rawValue]
public let kMediaTypes:Array<String> = {
   var array = Array<String>.init()
    array.append(contentsOf: kImageTypes)
    array.append(contentsOf: kVideoTypes)
    return array
}()
//[FilesFormatType.PNG.rawValue,FilesFormatType.JPG.rawValue,FilesFormatType.JPEG.rawValue,FilesFormatType.GIF.rawValue]

enum FilesFormatType:String {

    case EXE
    case PDF
    case PNG
    case JPG
    case JPEG
    case GIF
    case MP4
    case RMVB
    case RM
    case AVI
    case MKV
    case WMV
    case SWF
    case FLV
    case MOV
    case ThreeGP = "3GP"
    case MP3
    case AAC
    case WAV
    case FLAC
    case APE
    case TXT
    case PPT
    case PPTX
    case DOC
    case DOCX
    case XLS
    case XLSX
    case DEFAULT
}
