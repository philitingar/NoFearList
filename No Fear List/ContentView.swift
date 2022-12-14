//
//  ContentView.swift
//  No Fear List
//
//  Created by Timi on 12/12/22.
//
import MapKit
import SwiftUI

struct ContentView: View {
    //That will of course break a lot of code, but the fixes are easy – just add viewModel in various places. So, $mapRegion becomes $viewModel.mapRegion, locations becomes viewModel.locations, and so on.
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        if viewModel.isUnlocked { //isUnlocked reffers to faceID
            ZStack {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                    MapAnnotation(coordinate: location.coordinate ) {
                        VStack {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(Circle())
                            
                            Text(location.name)
                                .fixedSize()
                        }
                        .onTapGesture {
                            viewModel.selectedPlace = location
                        }
                    }
                }
                
                .ignoresSafeArea()
                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            viewModel.addLocation()
                            //function in viewmodel
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                    }
                }
            }
            
            .sheet(item: $viewModel.selectedPlace) { place in
                EditView(location: place) { newLocation in
                    viewModel.update(location: newLocation)
                    //changed the code as a function in viewModel
                }
            }
        } else { //to unlock the device with faceID
            Button("Unlock Places") {
                viewModel.authenticate()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
