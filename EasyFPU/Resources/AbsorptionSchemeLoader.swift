//
//  UserData.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 12.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CoreData

class AbsorptionSchemeLoader {
    private var defaultAbsorptionScheme: AbsorptionScheme
    private var absorptionScheme: AbsorptionScheme?
    @Environment(\.managedObjectContext) var managedObjectContext
    
    init() {
        // Load default absorption scheme
        let absorptionSchemeDefaultFile = "absorptionscheme_default.json"
        guard let file = Bundle.main.url(forResource: absorptionSchemeDefaultFile, withExtension: nil) else {
            fatalError("Unable to load \(absorptionSchemeDefaultFile)")
        }
        do {
            let data = try Data(contentsOf: file)
            let absorptionBlocks = AbsorptionSchemeLoader.decode(json: data, strategy: .convertFromSnakeCase) as [AbsorptionBlockFromJson]
            defaultAbsorptionScheme = AbsorptionScheme(absorptionBlocksFromJson: absorptionBlocks)
        } catch {
            fatalError("Could not decode data of \(absorptionSchemeDefaultFile):\n\(error.localizedDescription)")
        }
    }
    
    func getAbsorptionScheme() -> AbsorptionScheme {
        if absorptionScheme == nil {
            // Absorption scheme hasn't been loaded yet, so do it now
            let fetchRequest: NSFetchRequest<AbsorptionBlock> = AbsorptionBlock.fetchRequest()
            do {
                let absorptionBlocks = try fetchRequest.execute()
                if absorptionBlocks.isEmpty {
                    // Store default absorption blocks as user absorption blocks
                    for defaultAbsorptionBlock in defaultAbsorptionScheme.absorptionBlocks {
                        let newAbsorptionBlock = AbsorptionBlock(context: managedObjectContext)
                        newAbsorptionBlock.maxFpu = Int64(defaultAbsorptionBlock.maxFpu)
                        newAbsorptionBlock.absorptionTime = defaultAbsorptionBlock.absorptionTime
                    }
                    saveContext()
                }
                absorptionScheme = AbsorptionScheme(absorptionBlocks: absorptionBlocks)
            } catch {
                // Something went wrong, so return default absorption scheme
                debugPrint(error.localizedDescription)
                return defaultAbsorptionScheme
            }
        }
        
        return absorptionScheme!
    }
    
    func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
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
