//
//  BottomSheetImageInfoView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 16.12.2023.
//

import SwiftUI

struct BottomSheetImageInfoView: View {
    @Binding var isPresented: Bool
    var currentImage: UIImage
    var photoInfo: PhotoInfo
    
    init(
        isPresented: Binding<Bool>,
        currentImage: UIImage,
        photoInfo: PhotoInfo
    ) {
        _isPresented = isPresented
        self.currentImage = currentImage
        self.photoInfo = photoInfo
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Photo Info")
                    .font(.system(size: 19, weight: .bold))
                Spacer()
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.leading)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: 30, maxHeight: 30)
                })
            }
            .padding(.top, 30)
            .padding(.bottom, 30)
            List {
                VStack {
                    HStack {
                        Image(uiImage: currentImage)
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text(photoInfo.imageThermalName ?? "")
                                .font(.system(size: 18, weight: .regular))
                            HStack {
                                Text(photoInfo.fileSize ?? "")
                                    .foregroundStyle(.gray)
                                Text(" ")
                                Text(photoInfo.fileDateCreation ?? "")
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSeparator(.automatic)
            Spacer()
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(15)
    }
}
