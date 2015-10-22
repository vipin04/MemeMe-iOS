//
//  MeMeModel.swift
//  Meme iOS
//
//  Created by Vipin Aggarwal on 22/10/15.
//  Copyright © 2015 Vipin Aggarwal. All rights reserved.
//

import UIKit

class MeMeModel: NSObject {

    var topText:NSString = "";
    var bottomText:NSString = ""
    var originalImage:UIImage? = nil
    var modifiedImage:UIImage? = nil
    
    init (topText:NSString, bottomText:NSString, originalImage:UIImage, modifiedImage:UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.modifiedImage = modifiedImage
    }
}
