//
//  AppRoute.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import Foundation
import SwiftUI

enum AppRoute {
    case welcome
    case startConnection
    case scanning(isEmulatorLoading: Bool)
}

extension AppRoute: Hashable, Equatable {
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.welcome, .welcome): return true
        case (.startConnection, .startConnection): return true
        case (.scanning, .scanning): return true
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
