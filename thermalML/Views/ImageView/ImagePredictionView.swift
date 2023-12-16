//
//  ImageView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 16.12.2023.
//

import SwiftUI

struct ImagePredictionView: View {
    @StateObject private var viewModel: ImagePredictionViewModel
    @State private var isSheetPresented = false

    var currentImage: UIImage?
    var photoInfo: PhotoInfo?
    
    init(
        router: Router<AppRoute>,
        currentImage: UIImage,
        photoInfo: PhotoInfo
    ) {
        _viewModel = StateObject(
            wrappedValue: ImagePredictionViewModel(
                router: router
            )
        )
        self.currentImage = currentImage
        self.photoInfo = photoInfo
    }
    
    var body: some View {
        VStack {
            ZStack {
                if let image = currentImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 20)
                    
                } else {
                    Text("No image selected")
                }
                VStack {
                    Spacer()
                    Text(photoInfo?.imageThermalName ?? "")
                        .foregroundStyle(Color.red)
                }
            }
            Button(action: {
                //
            }, label: {
                HStack {
                    Image(systemName: "rectangle.and.text.magnifyingglass")
                        .padding(.leading)
                        .foregroundStyle(.black)
                    Text("Classify")
                        .foregroundColor(.black)
                        .padding(.trailing)
                }
                .frame(maxWidth: 125, maxHeight: 50)
                .background(Color(red: 255/255, green: 149/255, blue: 0/255, opacity: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.black)
            })
            .padding(.bottom, 20)
            HStack {
                Button(action: {
                        //
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .frame(width: 28, height: 28)
                Spacer()
                Button(action: {
                    isSheetPresented.toggle()
                    print("isSheetPresented: \(isSheetPresented)")
                }) {
                    Image(systemName: "info.circle")
                }
                .frame(width: 28, height: 28)
                Spacer()
                Button(action: {
                        //
                }) {
                    Image(systemName: "trash")
                }
                .frame(width: 28, height: 28)
            }
            .padding(.bottom)
            .padding(.horizontal)
        }
        .sheet(isPresented: $isSheetPresented) {
            if let currentImage = currentImage, let photoInfo = photoInfo {
                BottomSheetImageInfoView(isPresented: $isSheetPresented, currentImage: currentImage, photoInfo: photoInfo)
            }
        }
    }
}
