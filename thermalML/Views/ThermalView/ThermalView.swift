//
//  ThermalView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI
import CoreML
import PhotosUI

struct ThermalView: View {
    @StateObject var viewModel = ThermalViewModel()
    
    @State private var classificationLabel: String = .init()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
        
    var body: some View {
        VStack {
            Spacer()
            PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                            Text("Select a photo")
                        }.onChange(of: selectedItem) { newItem in
                            if let newItem = newItem {
                                Task {
                                    selectedImageData = try? await newItem.loadTransferable(type: Data.self)
                                    
                                    if let imageData = selectedImageData,
                                       let image = UIImage(data: imageData) {
                                        viewModel.loadImage(image)
                                    }
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
                viewModel.classifyImage()
                viewModel.processClassificationResults()
            }
            .padding()
            .foregroundColor(Color.white)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            // The Text View that we will use to display the results of the classification
            Text(viewModel.detail)
                .padding()
                .font(.body)
            Text(viewModel.recommendation)
                .padding()
                .font(.body)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ThermalView()
}
