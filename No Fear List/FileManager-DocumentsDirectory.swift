//
//  FileManager-DocumentsDirectory.swift
//  No Fear List
//
//  Created by Timi on 13/12/22.
//

import Foundation
extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
} //Now we can create a URL to a file in our documents directory wherever we want, however I don’t want to do that when both loading and saving files because it means if we ever change our save location we need to remember to update both places.
