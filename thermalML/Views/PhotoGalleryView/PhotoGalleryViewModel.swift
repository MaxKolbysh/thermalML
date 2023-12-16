//
//  PhotoGalleryViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import SwiftUI
import Combine
import CoreData

class PhotoGalleryViewModel: ObservableObject {
    @Published var photos: [PhotoInfo] = []
    unowned let router: Router<AppRoute>

    let fileManager = PhotoFileManager.shared

    private var dataManager: DataManager
    private var managedObjectContext: NSManagedObjectContext

    init(
        router: Router<AppRoute>,
        managedObjectContext: NSManagedObjectContext
    ) {
        self.router = router
        self.managedObjectContext = managedObjectContext
        self.dataManager = DataManager(context: managedObjectContext)
        loadPhotos()
    }
    
    func loadPhotos() {
        self.photos = dataManager.getAllImages()
        print("Загружено фотографий: \(photos.count)")
        for photo in photos {
            if let imagePathArray = photo.imageNameAndPath as? [String] {
                for imagePath in imagePathArray {
                    print("Путь к изображению: \(imagePath)")
                    if let photoData = fileManager.fetchPhoto(withPath: imagePath),
                       let image = UIImage(data: photoData) {
                    } else {
                        print("Ошибка загрузки фотографии по пути: \(imagePath)")
                    }
                }
            }
        }
    }
    
    func gotoImageView(currentImage: UIImage) {
        router.push(.imagePrediction(currentImage: currentImage))
    }
}
