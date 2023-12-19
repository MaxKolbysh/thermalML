//
//  BottomSheetInfoView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

struct BottomSheetView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Info")
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
            .padding(.horizontal, 30)
            
            VStack(alignment: .leading) {
                Text("This app utilizes the FLIR ONE® Edge Pro  thermal camera to provide you with enhanced features and functionalities. To fully experience the app's capabilities, please ensure you have a FLIR ONE thermal camera connected to your device.")
                
                Text(" FLIR ONE® Edge Pro")
                    .foregroundStyle(Color.blue)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 30)
            Image("cameraImageInfo")
            
            Text("To connect your FLIR ONE thermal camera, follow these simple steps:\n1. Ensure your FLIR ONE is turned on and within range of your device.\n2. Launch the app.\n3. A prompt will appear asking you to connect your FLIR ONE.\n4. Follow the on-screen instructions to complete the connection process.")
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(15)
    }
}
