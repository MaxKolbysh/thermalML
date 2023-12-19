//
//  PhotoGalleryAsyncLocalImage.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 17.12.2023.
//

import SwiftUI

struct AsyncLocalImage: View {
    let imagePath: String
    let loadImage: (String) async -> UIImage?
    @State private var image: UIImage?
    @State private var isLoading: Bool = false

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray
            }
        }
        .onAppear {
            isLoading = true
            Task {
                self.image = await loadImage(imagePath)
                isLoading = false
            }
        }
    }
}
