//
//  laMylApp.swift
//  laMyl
//
//  Created by Hoang Nguyen Van on 4/10/26.
//

import SwiftUI

@main
struct laMylApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty WindowGroup - app runs from menu bar only
        Settings {
            EmptyView()
        }
    }
}
