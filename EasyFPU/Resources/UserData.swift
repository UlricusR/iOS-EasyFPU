//
//  UserData.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 12.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

final class UserData: ObservableObject {
    var absorptionScheme: AbsorptionScheme
    
    init() {
        // Load default absorption scheme
        // TODO: Load individual absorption scheme instead
        let absorptionSchemeDefaultFile = "absorptionscheme_default.json"
        guard let file = Bundle.main.url(forResource: absorptionSchemeDefaultFile, withExtension: nil) else {
            fatalError("Unable to load \(absorptionSchemeDefaultFile)")
        }
        do {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let absorptionBlocks = try decoder.decode([AbsorptionBlock].self, from: data)
            absorptionScheme = AbsorptionScheme(absorptionBlocks: absorptionBlocks)
        } catch {
            fatalError("Could not decode data of \(absorptionSchemeDefaultFile)")
        }
    }
}
