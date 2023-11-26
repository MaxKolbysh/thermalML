//
//  NavViewBuilder.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

final class NavViewBuilder {
    unowned let router: Router<AppRoute>

    init(router: Router<AppRoute>) {
        self.router = router
    }
}
