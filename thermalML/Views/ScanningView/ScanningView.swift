//
//  ScanningView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//


import SwiftUI
import CoreML
import PhotosUI
import CoreData
    
struct ScanningView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @StateObject private var viewModel: ScanningViewModel
    
    @State private var errorMessage = ""
    @State private var isAlertPresented = false

    @State private var classificationLabel: String = .init()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State var isClassifyButtonDisable = true
    @State private var flashOpacity: Double = 0.0
    @State private var isBackAlertPresented = false
    
    private var isEmulatorLoading: Bool

    init(
        router: Router<AppRoute>,
        isEmulatorLoading: Bool,
        managedObjectContext: NSManagedObjectContext
    ) {
        _viewModel = StateObject(
            wrappedValue: ScanningViewModel(
                router: router,
                managedObjectContext: managedObjectContext
            )
        )
        self.isEmulatorLoading = isEmulatorLoading
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Rectangle()
                .background(Color.clear)
            ScanningCameraView(thermalImage: $viewModel.thermalImage)
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                ).overlay(
                    Color.black.opacity(flashOpacity)
                )
            
            if viewModel.isActivityIndicatorShowed {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(3, anchor: .center)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            
            Button(action: {
                if let image = viewModel.thermalImage {
                    Task {
                        await viewModel.savePhotos(thermalImage: image, originalImage: image)
                    }
                }
                if isClassifyButtonDisable {
                    isClassifyButtonDisable = false
                }
                withAnimation(.linear(duration: 0.05)) {
                    flashOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.linear(duration: 0.3)) {
                        flashOpacity = 0.0
                    }
                }
            }, label: {
                HStack {
                    Image(systemName: "camera")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: 50, maxHeight: 50)
                .background(Color(red: 0, green: 122/255, blue: 255/255, opacity: 1.0))
                .clipShape(Circle())
            })
            .padding(.bottom, 100)
            
            HStack {
                Spacer()
                Button(action: {
                    viewModel.gotoImageView()
                }, label: {
                    HStack {
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            .padding(.leading)
                            .foregroundStyle(.black)
                        Text("Classify")
                            .padding(.trailing)
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: 125, maxHeight: 50)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(.black)
                })
                .disabled(isClassifyButtonDisable)
            }
            .padding(.horizontal)
            .padding(.bottom, 100)

        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if isEmulatorLoading {
                if viewModel.isCameraConnected == nil || viewModel.isCameraConnected == false {
                    viewModel.connectEmulatorClicked()
                    viewModel.isCameraConnected = true
                }
                viewModel.isActivityIndicatorShowed = false
            } else {
                if viewModel.isCameraConnected == nil || viewModel.isCameraConnected == false {
                    viewModel.connectDeviceClicked()
                    viewModel.isCameraConnected = true
                }
                viewModel.isActivityIndicatorShowed = false
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            viewModel.streamStop()
            self.isBackAlertPresented = true
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.blue)
        }, trailing:
                Button(
                    action: {
                        viewModel.goToStartPhotoGalleryView()
                    }) {
                    Image(systemName: "photo")
                }
        )
        .onChange(of: viewModel.showAlert) { showAlert in
            if showAlert {
                viewModel.isActivityIndicatorShowed = false
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    isAlertPresented = false
                    viewModel.router.popToPrevious()
                }
            )
        }
        .alert(isPresented: $isBackAlertPresented) {
            Alert(
                title: Text("Confirm"),
                message: Text("Do you want to turn off the camera?"),
                primaryButton: .destructive(Text("Yes")) {
                    viewModel.disconnectClicked()
                    viewModel.router.pop()
                },
                secondaryButton: .cancel() {
                    viewModel.streamStart()
                }
            )
        }
    }
}
