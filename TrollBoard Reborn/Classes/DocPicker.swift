//
//  DocPicker.swift
//  TrollBoard Reborn
//
//  Created by haxi0 on 03.12.2023.
//

import UIKit
import MobileCoreServices

class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    var onDocumentPicked: (URL) -> Void
    
    init(onDocumentPicked: @escaping (URL) -> Void) {
        self.onDocumentPicked = onDocumentPicked
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            return
        }
        onDocumentPicked(selectedURL)
    }
}

func showDocumentPicker(delegate: DocumentPickerDelegate) {
    let documentPicker = UIDocumentPickerViewController(
        documentTypes: [kUTTypeFolder as String],
        in: .open
    )
    
    documentPicker.allowsMultipleSelection = false
    documentPicker.delegate = delegate
    UIApplication.shared.windows.first?.rootViewController?.present(
        documentPicker,
        animated: true,
        completion: nil
    )
}
