//
//  ContentView.swift
//  thermalML
//
//  Created by Smart Manufacturing and Robotics on 20.11.23.
//

import SwiftUI
import CoreML
import PhotosUI


struct ContentView: View {
    let model = thermalclassification_1()
    @State private var classificationLabel: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var currentIndex: Int = 0
    var body: some View {
        VStack {
            Spacer()
            PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Text("Select a photo")
                        }.onChange(of: selectedItem) { newItem in
                            Task {
                                // Retrieve selected asset in the form of Data
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    
                                    
                                }
                            }
                        }
            Spacer()
            
            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 299  , height: 299)
            }
        

            Button("Classify") {
                // Add more code here
                classifyImage()
            }
            .padding()
            .foregroundColor(Color.white)
            .background(Color.green)

            // The Text View that we will use to display the results of the classification
            Text(classificationLabel)
                .padding()
                .font(.body)
            Spacer()
        }
        .padding()
    }
    private func classifyImage() {
       
        //let currentImageName = photos[currentIndex]
        
        guard let image = UIImage(data: selectedImageData! ), /// maybe make sence to make normal unwrap
              let resizedImage = image.resizeImageTo(size:CGSize(width: 299, height: 299)),
              let buffer = resizedImage.convertToBuffer() else {
              return
        }
        
        let output = try? model.prediction(image: buffer)
        
        if let output = output {
            let results = output.targetProbability.sorted { $0.1 > $1.1 }
            let result = results.map { (key, value) in
                return "\(key) = \(String(format: "%.2f", value * 100))%"
            }.joined(separator: "\n")

            self.classificationLabel = result
        }
    }
}

#Preview {
    ContentView()
}
