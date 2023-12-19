//
//  PhotoGalleryView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import SwiftUI
import CoreData

struct PhotoGalleryView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @StateObject private var viewModel: PhotoGalleryViewModel
    @State var currentImage: UIImage?
    @State var photoInfo: PhotoInfo?
    
    init(
        router: Router<AppRoute>,
        managedObjectContext: NSManagedObjectContext
    ) {
        _viewModel = StateObject(
            wrappedValue: PhotoGalleryViewModel(
                router: router,
                managedObjectContext: managedObjectContext
            )
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            if viewModel.photos.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("The gallery is empty")
                            .font(.title)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.fixed((geometry.size.width - 32) / 3)),
                        GridItem(.fixed((geometry.size.width - 32) / 3)),
                        GridItem(.fixed((geometry.size.width - 32) / 3))
                    ], spacing: 8) {
                        ForEach(viewModel.photos, id: \.self) { photo in
                            if let imagePathArray = photo.imageNameAndPath as? [String],
                               let firstImagePath = imagePathArray.first
                            {
                            Button {
                                Task {
                                    await viewModel.gotoImageView(imagePath: firstImagePath, photoInfo: photo)
                                }
                            } label: {
                                ZStack {
                                    AsyncLocalImage(imagePath: firstImagePath, loadImage: viewModel.loadPhotoFromDisk)
                                        .frame(width: (geometry.size.width - 32) / 3, height: (geometry.size.width - 32) / 3)
                                    VStack {
                                        Spacer()
                                        Text(photo.imageThermalName ?? "")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 10, weight: .light))
                                            .padding(.bottom, 10)
                                    }
                                }
                            }
                            }
                        }
                    }
                    
                }
                .navigationTitle(Text("Gallery"))
                .onAppear {
                    Task {
                        await viewModel.loadPhotosInfoFromDB()
                    }
                }
                .onChange(of: viewModel.photos) { _ in
                    Task {
                        await viewModel.loadPhotosInfoFromDB()
                    }
                }
            }
        }
    }
}
