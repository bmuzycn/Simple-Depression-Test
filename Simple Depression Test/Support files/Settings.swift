//
//  Settings.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 1/14/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import UIKit

class Settings {
    static var textFont = UIFont.preferredFont(forTextStyle: .body)
    static var headFont = UIFont.preferredFont(forTextStyle: .headline)
    static var titleFont = UIFont.preferredFont(forTextStyle: .title1)
    @available(iOS 11.0, *)
    static var largeTitleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
    static var textColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
    static var bgColorForTextField = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static var bgColorForMenuView = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 0.9)
    static var bgColorForTableView = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static var colorForHeadView = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
    static var bgImage = UIImage(named: "bgImage")
}
