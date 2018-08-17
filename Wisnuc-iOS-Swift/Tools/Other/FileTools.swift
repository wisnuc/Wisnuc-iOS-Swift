//
//  FileTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
class FileTools: NSObject {
  class func switchFilesFormatType(type:FilesType?, format:FilesFormatType?) -> String{
        if type == nil {
            return "file_icon.png"
        }
        var name:String!
        if type == .directory {
            name = "files_folder.png"
        }else{
            switch format {
            case .PDF?:
                name = "files_pdf_small.png"
            case .PNG?,.JPG?,.JPEG?:
                name = "files_photo_normal.png"
            case .DOC?,.DOCX?:
                name = "files_word_small.png"
            case .PPT?,.PPTX?:
                name = "files_ppt_small.png"
            case .XLS?,.XLSX?:
                name = "files_excel_small.png"
            default:
                name = "file_icon.png"
            }
        }
        return name
    }
    
    class func switchFilesFormatTypeNormalImage(type:FilesType?, format:FilesFormatType?) -> String{
        if type == nil {
            return "file_icon.png"
        }
        var name:String!
        if type == .directory {
            name = "files_folder.png"
        }else{
            switch format {
            case .PDF?:
                name = "files_pdf_normal.png"
            case .PNG?,.JPG?,.JPEG?:
                name = "files_photo_normal.png"
            case .DOC?,.DOCX?:
                name = "files_word_normal.png"
            case .PPT?,.PPTX?:
                name = "files_ppt_normal.png"
            case .XLS?,.XLSX?:
                name = "files_excel_normal.png"
            default:
                name = "file_icon.png"
            }
        }
        return name
    }
    
    
    class func fileSizeAtPath(filePath:String)->UInt64{
        
        let manager = FileManager.default
        
        if manager.fileExists(atPath: filePath){
            
            do{
                let size:UInt64 = try manager.attributesOfItem(atPath: filePath)[FileAttributeKey.size] as! UInt64
                return size
            }catch{
                return 0
            }
        }
        
        return 0
    }
}
