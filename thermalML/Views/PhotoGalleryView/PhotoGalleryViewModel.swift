//
//  PhotoGalleryViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import SwiftUI
import Combine

class PhotoGalleryViewModel: ObservableObject {
    unowned let router: Router<AppRoute>
    @Published var photos: [PhotoInfo] = []

    init(router: Router<AppRoute>) {
        self.router = router
//        loadPhotos()
    }
    
//    func loadPhotos() {
//        self.photos = DataManager.getAllImages()
//    }
}
