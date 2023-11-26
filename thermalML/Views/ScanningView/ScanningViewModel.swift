//
//  ThermalViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import Foundation
import CoreML
import SwiftUI

class ScanningViewModel: ObservableObject {
    unowned let router: Router<AppRoute>
    
    @Published var detail: String = .init()
    @Published var recommendation: String = .init()

    private let mlModel: thermalclassification_1
    private let imageModel = ScanningPictureModel()

    let renderQueue = DispatchQueue.init(label: "render")

    var classificationResults: [String: Double] = .init()
    
    init(router: Router<AppRoute>) {
        self.router = router
        
        do {
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .cpuOnly
            mlModel = try thermalclassification_1(configuration: configuration)
            print("Model loaded successfully")
        } catch {
            print("Error loading model: \(error)")
            fatalError("Unable to load the thermalclassification_1 model.")
        }
    }
    
    func loadImage(_ image: UIImage) {
        imageModel.image = image
    }
    
//    func onImageReceived() {
//        renderQueue.async {
//            do {
//                try self.thermalStreamer?.update()
//            } catch {
//                NSLog("update error \(error)")
//            }
//            let image = self.thermalStreamer?.getImage()
//            DispatchQueue.main.async {
//                self.thermalPictureModel.image = image
//            }
//        }
//    }
    
    func classifyImage() {
        
        guard let image = imageModel.image,
            let resizedImage = image.resizeImageTo(size: CGSize(width: 299, height: 299)),
              let buffer = resizedImage.convertToBuffer() else {
            print("Failed to create pixel buffer from UIImage")
            return
        }
        print("Buffer: \(buffer)")
        
        do {
            let input = thermalclassification_1Input(image: buffer)
            let output = try mlModel.prediction(input: input)
            print("Classified image as: \(output.target)")
            print("Prediction probabilities: \(output.targetProbability)")
            classificationResults = output.targetProbability
            let results = output.targetProbability.sorted { $0.1 > $1.1 }
            detail = results.map { (key, value) in
                return "\(key) = \(String(format: "%.2f", value * 100))%"
            }.joined(separator: "\n")
        } catch {
            print("Error during classification: \(error)")
        }
    }
    
    func processClassificationResults() {
        // Sort the results by probability
        let sortedResults = classificationResults.sorted { $0.value > $1.value }
        
        guard let highestResult = sortedResults.first else {
            recommendation = "Unable to identify the object."
            return
        }

        // Form a recommendation based on the most probable result
        switch highestResult.key {
        case "hot object":
            recommendation = "Hot object detected. Insulation check recommended."
        case "hot object hotfloor":
            recommendation = "Signs of heat leakage on the floor and other objects detected."
        case "cold object hotfloor":
            recommendation = "Cold objects detected with heat leakage on the floor."
        case "cold floor":
            recommendation = "The floor is cold. Improved insulation may be needed."
        case "hotfloor":
            recommendation = "The floor is hot. Check the heating system or for heat leaks."
        case "cold object hot object hotfloor":
            recommendation = "A combination of cold and hot objects detected. Detailed analysis required."
        default:
            recommendation = "Object status is undefined."
        }
    }
}
