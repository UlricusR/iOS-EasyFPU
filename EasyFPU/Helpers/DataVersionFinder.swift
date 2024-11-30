//
//  DataVersionFinder.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 17/08/2023.
//  Copyright © 2023 Ulrich Rüth. All rights reserved.
//

import Foundation

enum DataModelVersion: String {
    case version1 = "EasyFPU"
    case version2 = "EasyFPU 2"
}

class DataVersionFinder: Decodable {
    var dataModelVersion: DataModelVersion
    enum CodingKeys: String, CodingKey {
        case dataModelVersion
    }
    enum DataModelError: Error {
        case invalidDataModelVersion(String)
    }
    
    required init(from decoder: Decoder) throws {
        var dataModelVersionString: String
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            dataModelVersionString = try container.decode(String.self, forKey: .dataModelVersion)
        } catch {
            // This must be version 1, as no dataModelVersion was found
            dataModelVersionString = DataModelVersion.version1.rawValue
        }
        
        // We need to read it from the parameter
        guard let dataModelVersion = DataModelVersion(rawValue: dataModelVersionString) else {
            throw DataModelError.invalidDataModelVersion("'" + dataModelVersionString + "' " + NSLocalizedString("is not a valid data model", comment: ""))
        }
        self.dataModelVersion = dataModelVersion
    }
}
