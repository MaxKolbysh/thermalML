//
//  ScanningView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//


import SwiftUI
import CoreML
import PhotosUI
    
struct ScanningView: View {
    @StateObject var viewModel: ScanningViewModel
    
    @State private var classificationLabel: String = .init()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    init(router: Router<AppRoute>) {
        _viewModel = StateObject(wrappedValue: ScanningViewModel(router: router))
        
        
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScanningCameraView(thermalImage: $viewModel.thermalImage)
                    .background(Color.orange)
                Button(action: {
                        //
                }, label: {
                    HStack {
                        Image(systemName: "camera")
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: 50, maxHeight: 50)
                    .background(Color(red: 0, green: 122/255, blue: 255/255, opacity: 1.0))
                    .clipShape(Circle())
                    .foregroundColor(.black)
                })
                .padding(.bottom, 30)

                HStack {
                    Spacer()
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
                        .background(Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.24))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.black)
                    })
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
        }
        .onAppear {
            viewModel.connectEmulatorClicked()
            
        }
        .navigationBarItems(trailing:
                                Button(action: {
            print("Gallery Button Tapped")
        }) {
            Image(systemName: "photo")
        }
        )
    }
}

#Preview {
    ScanningView(router: Router())
}
