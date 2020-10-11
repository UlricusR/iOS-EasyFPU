//
//  MealExportViewActionSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class MealExportViewActionSheets {
    enum State: Identifiable {
        case confirmExportWithinAlertPeriod
        case confirmExport
        
        var id: State { self }
    }
}
