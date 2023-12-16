//
//  MainFlow.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

protocol MainFlow {
    associatedtype Welcome: View
    associatedtype StartConnection: View
    associatedtype Scanning: View
    associatedtype PhotoGallery: View
    associatedtype ImagePrediction: View

    func createWelcomeView() -> Welcome
    func createStartConnectionView() -> StartConnection
    func createScanningView(isEmulatorLoading: Bool) -> Scanning
    func createPhotoGalleryView() -> PhotoGallery
    func createImagePredictionView(currentImage: UIImage,
                                   photoInfo: PhotoInfo,
                                   photoFileManager: PhotoFileManager,
                                   dataManager: DataManager) -> ImagePrediction

}

extension NavViewBuilder: MainFlow {
    func createWelcomeView() -> some View {
        WelcomeView(router: router)
    }
    func createStartConnectionView() -> some View {
        StartConnectionView(router: router)
    }
    func createScanningView(isEmulatorLoading: Bool) -> some View {
        ScanningView(router: router, isEmulatorLoading: isEmulatorLoading, managedObjectContext: managedObjectContext)
    }
    func createPhotoGalleryView() -> some View {
        PhotoGalleryView(router: router, managedObjectContext: managedObjectContext)
    }
    func createImagePredictionView(currentImage: UIImage,
                                   photoInfo: PhotoInfo,
                                   photoFileManager: PhotoFileManager,
                                   dataManager: DataManager) -> some View { ImagePredictionView(router: router,
                                                                                                currentImage: currentImage,
                                                                                                photoInfo: photoInfo,
                                                                                                photoFileManager: photoFileManager,
                                                                                                dataManager: dataManager)
    }
}
