//
//  ScanningViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI
import Combine

class ScanningViewModel: ObservableObject {
    unowned let router: Router<AppRoute>
    @State private var cameraManager = FLIRCameraManager()
    
    @Published var centerSpotText: String = ""
    @Published var distanceText: String = ""
    @Published var distanceValue: Float = 0.0
    @Published var thermalImage: UIImage?
    @Published var scaleImage: UIImage?
    @Published var currentImage: UIImage?

    
    private var cancellables = Set<AnyCancellable>()

    init(router: Router<AppRoute>) {
        self.router = router
        
        cameraManager.$centerSpotText
            .compactMap { $0 }
            .assign(to: \.centerSpotText, on: self)
            .store(in: &cancellables)

        cameraManager.$distanceText
            .compactMap { $0 }
            .assign(to: \.distanceText, on: self)
            .store(in: &cancellables)
        
        cameraManager.$distanceValue
            .compactMap { $0 }
            .assign(to: \.distanceValue, on: self)
            .store(in: &cancellables)
        
        cameraManager.$currentImage
            .assign(to: \.currentImage, on: self)
            .store(in: &cancellables)
        
        cameraManager.$thermalImage
            .assign(to: \.thermalImage, on: self)
            .store(in: &cancellables)

        cameraManager.$thermalImage
            .assign(to: \.thermalImage, on: self)
            .store(in: &cancellables)
        
        cameraManager.$scaleImage
            .assign(to: \.scaleImage, on: self)
            .store(in: &cancellables)
    }
    
    func connectDeviceClicked() {
        cameraManager.connectDeviceClicked()
    }
    
    func disconnectClicked() {
        cameraManager.disconnectClicked()
    }
    
    func connectEmulatorClicked() {
        print("connectEmulatorClicked")
        cameraManager.connectEmulatorClicked()
    }
    
    func ironPaletteClicked() {
        cameraManager.ironPaletteClicked()
    }
}
