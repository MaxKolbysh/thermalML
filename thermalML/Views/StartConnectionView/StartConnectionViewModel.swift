//
//  StartConnectionViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

class StartConnectionViewModel: ObservableObject {
    unowned let router: Router<AppRoute>
    
    init(router: Router<AppRoute>) {
        self.router = router
    }
    
    func goToScanningView(isEmulatorLoading: Bool) {
        router.push(.scanning(isEmulatorLoading: isEmulatorLoading))
    }
}
