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
        loadPhotosInfoFromDB()
    }
    
    // MARK: - Get photo info from DB
    func loadPhotosInfoFromDB() {
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
    
    func loadPhotoFromDisk(from path: String) -> UIImage? {
        print("Загрузка изображения по пути: \(path)")
        if let photoData = fileManager.fetchPhoto(withPath: path),
           let image = UIImage(data: photoData) {
            return image
        } else {
            print("Не удалось загрузить изображение по пути: \(path)")
            return nil
        }
    }
    
    func gotoImageView(currentImage: UIImage, photoInfo: PhotoInfo) {
        router.push(.imagePrediction(
            currentImage: currentImage,
            photoInfo: photoInfo,
            photoFileManager: fileManager,
            dataManager: dataManager
        ))
    }
}
