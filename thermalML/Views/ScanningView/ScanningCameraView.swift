//
//  ScanningCameraView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI
import UIKit

struct ScanningCameraView: UIViewRepresentable {
    @Binding var thermalImage: UIImage?

    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = thermalImage
    }
}
