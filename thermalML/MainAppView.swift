//
//  MainAppView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

struct MainAppView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @StateObject var router: Router<AppRoute>
    let navViewBuilder: NavViewBuilder

    var body: some View {
        NavigationStack(path: $router.paths) {
            navViewBuilder.createWelcomeView()
                .navigationDestination(for: AppRoute.self, destination: buildViews)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            handleAppDidEnterBackground()
        }
    }

    @ViewBuilder
    private func buildViews(view: AppRoute) -> some View {
        switch view {
        case .welcome: navViewBuilder.createWelcomeView()
        case .startConnection: navViewBuilder.createStartConnectionView()
        case .scanning(let isEmulatorLoading): navViewBuilder.createScanningView(isEmulatorLoading: isEmulatorLoading)
        case .photoGallery: navViewBuilder.createPhotoGalleryView()
        case .imagePrediction(
            let currentImage,
            let photoInfo,
            let photoFileManager,
            let dataManager): navViewBuilder.createImagePredictionView(
                currentImage: currentImage,
                photoInfo: photoInfo,
                photoFileManager: photoFileManager,
                dataManager: dataManager
            )
        }
    }
    
    private func handleAppDidEnterBackground() {
        if let isCameraConnected = FLIRCameraManager.shared.isCameraConnected {
            if isCameraConnected {
                FLIRCameraManager.shared.cleanup()
            }
        }
        router.popToRoot()
    }
}
