//
//  FilePickerView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct FilePickerController: UIViewControllerRepresentable {
    var callback: (URL) -> ()
    var documentTypes: [UTType]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePickerController>) {
        // Update the controller
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        debugPrint("Making the picker")
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes)
        
        controller.delegate = context.coordinator
        debugPrint("Setup the delegate \(context.coordinator)")
        
        return controller
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerController
        
        init(_ pickerController: FilePickerController) {
            self.parent = pickerController
            debugPrint("Setup a parent")
            debugPrint("Callback: \(String(describing: parent.callback))")
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt: [URL]) {
            debugPrint("Selected a document: \(didPickDocumentsAt[0])")
            parent.callback(didPickDocumentsAt[0])
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            debugPrint("Document picker was thrown away :(")
        }
        
        deinit {
            debugPrint("Coordinator going away")
        }
    }
}

struct FilePickerView: View {
    var callback: (URL) -> ()
    var documentTypes: [UTType]
    var body: some View {
        FilePickerController(callback: callback, documentTypes: documentTypes)
    }
}
