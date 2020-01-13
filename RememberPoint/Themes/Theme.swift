//
//  Theme.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 04/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static var primaryColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor.systemIndigo
        } else {
            return UIColor(red: 120 / 255, green: 105 / 255, blue: 245 / 255, alpha: 1)
        }
    }

    static var secondaryColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor.secondarySystemGroupedBackground
        } else {
            return UIColor(red: 247 / 255, green: 246 / 255, blue: 251 / 255, alpha: 1)
        }
    }
}

final class Theme {
    private init() {}
    static func initAppearance() {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .primaryColor

        // Swift BUG: in iOS 13 isTranslucent = false is cause of bug with incorect position
        // for the search results table in UISearchController
        // https://stackoverflow.com/questions/57521967/ios-13-strange-search-controller-gap
        UINavigationBar.appearance().isTranslucent = false

        UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .black
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .white
    }
}
