//
//  WelcomeViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import Foundation
import SwiftUI

class WelcomeViewModel: ObservableObject {
    unowned let router: Router<AppRoute>

    init(router: Router<AppRoute>) {
        self.router = router
    }
    
    func goToStartConnectionView() {
        router.push(.startConnection)
    }
    
    func goToStartPhotoGalleryView() {
        router.push(.photoGallery)
    }
}
