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
            let absorptionBlocks = UserData.decode(json: data, strategy: .convertFromSnakeCase) as [AbsorptionBlockFromJson]
            absorptionScheme = AbsorptionScheme(absorptionBlocksFromJson: absorptionBlocks)
        } catch {
            fatalError("Could not decode data of \(absorptionSchemeDefaultFile):\n\(error.localizedDescription)")
        }
    }
    
    //
    // Data helpers
    //
    
    static private func decode<T: Decodable>(json data: Data, strategy: JSONDecoder.KeyDecodingStrategy) -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = strategy
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse data as \(T.self):\n\(error.localizedDescription)")
        }
    }
}
