//
//  ContentView-ViewModel.swift
//  No Fear List
//
//  Created by Timi on 13/12/22.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView {
    //The main actor is responsible for running all user interface updates, and adding that attribute to the class means we want all its code – any time it runs anything, unless we specifically ask otherwise – to run on that main actor. This is important because it’s responsible for making UI updates, and those must happen on the main actor. In practice this isn’t quite so easy, but we’ll come to that later on.
    //So, by adding the @MainActor attribute here we’re taking a “belt and braces” approach: we’re telling Swift every part of this class should run on the main actor, so it’s safe to update the UI, no matter where it’s used.
    @ MainActor class ViewModel: ObservableObject {
        // Let’s start with the easy stuff: move all three @State properties in ContentView over to its view model, switching @State private for just @Published – they can’t be private any more, because they explicitly need to be shared with ContentView:
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        //Reading data from a view model’s properties is usually fine, but writing it isn’t because the whole point of this exercise is to separate logic from layout. You can find these two places immediately if we clamp down on writing view model data – modify the locations property in your view model to this:
        @Published private(set) var locations = [Location]()
        @Published var selectedPlace: Location?
        
        @Published var isUnlocked = false //for face unlock
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        init () {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
            locations.append(newLocation)
        }
        func update(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
            }
        }
         //1.Creating an LAContext so we have something that can check and perform biometric authentication. 2.Ask it whether the current device is capable of biometric authentication. 3.If it is, start the request and provide a closure to run when it completes. 4.When the request finishes, check the result. 5.If it was successful, we’ll set isUnlocked to true so we can run our app as normal.

        func authenticate() { //for face authentification
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

                    if success {
                        //Next to that it should say “publishing changes from background threads is not allowed”, which translated means “you’re trying to change the UI but you’re not doing it from the main actor and that’s going to cause problems.”
                        //The solution here is to make sure we change the isUnlocked property on the main actor. This can be done by starting a new task, then calling await MainActor.run() inside there, like this:we can tell Swift that our task’s code needs to run directly on the main actor, by giving the closure itself the @MainActor attribute. So, rather than bouncing to a background task then back to the main actor, the new task will immediately start running on the main actor:
                        Task { @MainActor in
                                self.isUnlocked = true
                            }
                    } else {
                        // error
                    }
                }
            } else {
                // no biometrics
            }
        }
    }
}
