extension UTType {
    static var foodDataType: UTType = .init(exportedAs: "info.rueth.EasyFPU.fooddata", conformingTo: .json)
}

struct FoodDataDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [ UTType(filenameExtension: "fooddata", conformingTo: .foodDataType)! ]
    }
    
    private var jsonContent: Data
    
    /// Creates an empty Data object for jsonContent, only required for the .fileExport modifier
    init() {
        jsonContent = Data()
    }
    
    /// Creates a JSON Data object from the passed FoodItemViewModels and ComposedFoodItemViewModels..
    /// - Parameter errorMessage: The error message if initialization fails
    init?(foodItems: [FoodItemViewModel], composedFoodItems: [ComposedFoodItemViewModel], errorMessage: inout String) {
        // Prepare the DataWrapper
        let dataWrapper = DataWrapper(dataModelVersion: .version2, foodItemVMs: foodItems, composedFoodItemVMs: composedFoodItems)
        
        // Encode
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            jsonContent = try encoder.encode(dataWrapper)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            jsonContent = data
        } else {
            // Create an empty Data object
            jsonContent = Data()
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: jsonContent)
    }
}

