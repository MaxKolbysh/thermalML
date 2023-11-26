//
//  TemporaryView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel: WelcomeViewModel
    @State private var isSheetPresented = false

    init(router: Router<AppRoute>) {
        _viewModel = StateObject(wrappedValue: WelcomeViewModel(router: router))
    }
    
    var body: some View {
        VStack {
            Image("mainLogo")
                .padding(.top, 120)
                .edgesIgnoringSafeArea(.top)
            Text("Welcome to thermal app")
                .font(.system(size: 17, weight: .black))
            Spacer()
            Button(action: {
                viewModel.goToStartConnectionView()
            }, label: {
                HStack {
                    Image(systemName: "play.fill")
                        .padding(.leading)
                        .foregroundStyle(.white)
                    Text("Start inspection")
                        .foregroundColor(.white)
                        .padding(.trailing)
                }
                .frame(maxWidth: 190, maxHeight: 50)
                .background(Color(red: 0, green: 122/255, blue: 255/255, opacity: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.white)
            })
            Button(action: {
                viewModel.goToStartConnectionView()
            }, label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading)
                        .foregroundStyle(.black)
                    Text("Saved Scans")
                        .foregroundColor(.black)
                        .padding(.trailing)
                }
                .frame(maxWidth: 161, maxHeight: 50)
                .background(Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.24))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.black)
            })
            Spacer()
            Button(action: {
                isSheetPresented.toggle()
            }, label: {
                HStack {
                    Image(systemName: "info.circle")
                        .padding(.leading)
                        .foregroundStyle(.black)
                }
                .foregroundColor(.black)
            })
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $isSheetPresented) {
            BottomSheetView(isPresented: $isSheetPresented)
        }
    }
}

#Preview {
    WelcomeView(router: Router())
}
