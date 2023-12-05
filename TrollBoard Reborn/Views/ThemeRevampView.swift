//
//  ThemeRevampView.swift
//  TrollBoard Reborn
//
//  Created by haxi0 on 03.12.2023.
//

import SwiftUI

struct ThemesFolder: Identifiable {
    let id = UUID()
    let folder: String
    let fileCount: Int
    let randomIcon: String?
}

struct ThemeRevampView: View {
    @State private var iconPacks: [ThemesFolder] = []
    @State private var selectedFolderURL: URL?
    @State private var documentPickerDelegate: DocumentPickerDelegate?
    @State private var iconLabels = true
    @State private var presentAlert = false
    
    let themesFolder = "/var/mobile/.TrollBoard"
    let fm = FileManager.default
    let WBC = Webcon.shared
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(iconPacks.indices, id: \.self) { index in
                        let iconPack = iconPacks[index]
                        let iconPackFolder = "\(themesFolder)/\(iconPack.folder)"
                        let iconPath = "\(themesFolder)/\(iconPack.folder)/\(iconPack.randomIcon ?? "")"
                        
                        HStack {
                            Image(uiImage: UIImage(contentsOfFile: URL(fileURLWithPath: iconPath).path) ?? UIImage(named: "DefaultIcon")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(iconPack.folder)
                                    .bold()
                                    .onTapGesture {
                                        UIApplication.shared.alertWithTextField(title: "New Icon Pack Name", body: "Ex. Felicity Pro", placeholder: "Name") { newName in
                                            if !newName.isEmpty {
                                                do {
                                                    try fm.moveItem(atPath: iconPackFolder, toPath: "\(themesFolder)/\(newName)")
                                                    
                                                    Task {
                                                        await refreshFolders()
                                                    }
                                                } catch {
                                                    UIApplication.shared.alert(title: "Error Renaming Pack!", body: "Error: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                    }
                                Text("\(iconPack.fileCount) Icons")
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if iconPack.fileCount.description != "0" {
                                Button("Add") {
                                    applyPack(pack: iconPackFolder, withLabel: iconLabels)
                                }
                                .buttonStyle(.borderedProminent)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .onDelete { indices in
                        for index in indices {
                            if iconPacks.indices.contains(index) {
                                let folderToDelete = iconPacks[index]
                                
                                iconPacks.remove(at: index)
                                
                                let folderPath = "/var/mobile/.TrollBoard/\(folderToDelete.folder)"
                                do {
                                    try fm.removeItem(atPath: folderPath)
                                } catch {
                                    UIApplication.shared.alert(title: "Error deleting pack", body: "Error: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Toggle("Icon Labels", isOn: $iconLabels)
                } footer: {
                    Text("Thanks to AppInstalleriOS, h3nda, Allie, bonnie, C22! ♡")
                }
            }
            .navigationTitle("TrollBoard Reborn")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await refreshFolders()
            }
            .onAppear {
                if tsCheck() {
                    Task {
                        await refreshFolders()
                    }
                }
            }
            .toolbar {
                Button {
                    importPack()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                
                Button {
                    respring()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    
    private func refreshFolders() async {
        do {
            let folderContents = try await fm.contentsOfDirectory(atPath: themesFolder)
            
            self.iconPacks = try await withThrowingTaskGroup(of: ThemesFolder.self) { group in
                for folder in folderContents {
                    group.addTask {
                        let itemPath = (themesFolder as NSString).appendingPathComponent(folder)
                        var isDirectory: ObjCBool = false
                        
                        guard fm.fileExists(atPath: itemPath, isDirectory: &isDirectory) && isDirectory.boolValue else {
                            return ThemesFolder(folder: "", fileCount: 0, randomIcon: nil)
                        }
                        
                        let pngFiles = try fm.contentsOfDirectory(atPath: itemPath)
                            .filter { $0.hasSuffix(".png") }
                        
                        let fileCount = pngFiles.count
                        let randomIcon = pngFiles.randomElement()
                        
                        return ThemesFolder(folder: folder, fileCount: fileCount, randomIcon: randomIcon)
                    }
                }
                
                return try await group.reduce(into: []) { result, folder in
                    result.append(folder)
                }
            }
        } catch {
            if !tsCheck() {
                await UIApplication.shared.alert(title: "Failed to List Themes!", body: "Error: \(error.localizedDescription)", withButton: false)
            }
            
            self.iconPacks = []
        }
    }
    
    private func tsCheck() -> Bool {
        do {
            if fm.fileExists(atPath: themesFolder) {
                print("Directory exists, no need to create")
            } else {
                try fm.createDirectory(atPath: themesFolder, withIntermediateDirectories: false)
            }
            
            return true
        } catch {
            UIApplication.shared.alert(title: "TrollStore Check Failed!", body: "This means the app wasn't installed with TrollStore or it's missing something. Error: \(error.localizedDescription)", withButton: false)
            return false
        }
    }
    
    private func importPack() {
        documentPickerDelegate = DocumentPickerDelegate { selectedURL in
            self.selectedFolderURL = selectedURL
            
            do {
                try fm.copyItem(at: selectedFolderURL!, to: URL(fileURLWithPath: "\(themesFolder)/\(selectedURL.lastPathComponent.description)"))
                
                Task {
                    await refreshFolders()
                }
            } catch {
                UIApplication.shared.alert(title: "Error Importing Icon Pack!", body: "Error: \(error.localizedDescription)")
            }
        }
        showDocumentPicker(delegate: documentPickerDelegate!)
    }
    
    private func applyPack(pack: String, withLabel: Bool) {
        do {
            UIApplication.shared.alert(title: "Applying", body: "Please wait and don't exit the app...", withButton: false)
            
            let pngFiles = try fm.contentsOfDirectory(atPath: pack)
                .filter { $0.hasSuffix(".png") } // only grab png files
            
            for pngFile in pngFiles { // loop
                if SBFApplication(applicationBundleIdentifier: pngFile.replacingOccurrences(of: "-large", with: "").replacingOccurrences(of: ".png", with: "")).displayName ?? "Unknown" == "Unknown" { // check if device has bundle id grabed from png, if it doesnt ignore that png
                    print("Bundle ID not found, skipping")
                } else {
                    WBC.applyIcon(pngData: try Data(contentsOf: URL(fileURLWithPath: "\(pack)/\(pngFile)")), pngName: pngFile, withLabel: withLabel) // apply icon
                }
            }
            
            UIApplication.shared.dismissAlert(animated: false)
            UIApplication.shared.confirmAlert(title: "Finished!", body: "Finished adding all WebClips to your homescreen. Respring now?", onOK: {
                respring()
            }, noCancel: false)
        } catch {
            UIApplication.shared.dismissAlert(animated: false)
            UIApplication.shared.alert(title: "Error Adding Pack!", body: "Error: \(error.localizedDescription)")
        }
    }
}
