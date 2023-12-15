//
//  PhotoGalleryView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import SwiftUI

struct PhotoGalleryView: View {
    @StateObject private var viewModel: PhotoGalleryViewModel
    
    init(router: Router<AppRoute>) {
        _viewModel = StateObject(wrappedValue: PhotoGalleryViewModel(router: router))
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(viewModel.photos, id: \.self) { photo in
                    if let image = UIImage(contentsOfFile: photo.imagePath ?? "") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }
            }
        }
    }
}
