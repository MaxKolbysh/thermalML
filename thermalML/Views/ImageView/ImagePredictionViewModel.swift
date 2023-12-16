//
//  ImageViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 16.12.2023.
//

import Foundation

class ImagePredictionViewModel: ObservableObject {
    unowned let router: Router<AppRoute>

    init(
        router: Router<AppRoute>
    ) {
        self.router = router
    }
    
}
