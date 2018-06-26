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
            case .PNG?,.JPG?:
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
}
