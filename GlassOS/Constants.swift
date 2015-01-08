//
//  Constants.swift
//  GlassOS
//
//  Created by Timothy Tong on 2015-01-05.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import Foundation
class Constants{
    class func translationURL()->String{
        return "https://translate.google.com/#en/zh-CN/"
    }
    class func appVersion()->Float{
        return 0.1
    }
    class func screenSize()->CGSize{
        return UIScreen.mainScreen().bounds.size
    }
}
