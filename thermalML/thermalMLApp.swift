//
//  thermalMLApp.swift
//  thermalML
//
//  Created by Smart Manufacturing and Robotics on 20.11.23.
//

import SwiftUI

@main
struct ThermalMLApp: App {
    var body: some Scene {
        let router: Router<AppRoute> = .init()
        let builder: NavViewBuilder = .init(router: router)

        WindowGroup {
            MainAppView(router: router, navViewBuilder: builder)
        }
    }
}
