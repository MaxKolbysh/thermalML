//
//  ScanningCameraView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI
//import UIKit

//struct ScanningCameraView: UIViewRepresentable {
//    @Binding var thermalImage: UIImage?
//
//    func makeUIView(context: Context) -> UIImageView {
//        let imageView = UIImageView()
//        print("imageView.bounds: \(imageView.bounds)")
//        print("ScanningCameraView we are here")
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }
//
//    func updateUIView(_ uiView: UIImageView, context: Context) {
//        print("updateUIView called")
//        uiView.image = thermalImage
//        uiView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        print("updateUIView imageView bounds: \(uiView.bounds)")
//    }
//}

import SwiftUI

struct ScanningCameraView: View {
    @Binding var thermalImage: UIImage?
    
    var body: some View {
        if let thermalImage = thermalImage {
            Image(uiImage: thermalImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}
