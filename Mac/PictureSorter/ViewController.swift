
//
//  ViewController.swift
//  PictureSorter
//
//  Created by Zenel Kazushi on 9/9/17.
//  Copyright © 2017 Zenel Kazushi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var imageViewPreview: NSImageView!
    @IBOutlet var buttonSelectFolder: NSButton!
    var inputPath: URL?
    var imageFiles: [URL]?
    var currentImageIndex: Int = -1
    
    override func keyDown(with event: NSEvent) {
        if event.type != .keyDown || imageFiles == nil {
            return
        }
        guard let name = folderName(for: event) else {
            return
        }
        copyFile(to: name)
    }
    
    private static func isImage(_ path: URL) -> Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, path.pathExtension as CFString, nil)?.autorelease() else {
            fatalError("Could not build UTI Type!")
        }
        return UTTypeConformsTo(uti.takeUnretainedValue(), kUTTypeImage)
    }
    
    @IBAction func onButtonSelectFolderClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        let clicked = openPanel.runModal()
        if clicked == NSFileHandlingPanelOKButton {
            inputPath = openPanel.url
            guard inputPath != nil else {
                fatalError("Open panel succeeded, but selected no paths!")
            }
            startShowingPictures()
        }
    }
    
    private func startShowingPictures() {
        guard let inputPath = inputPath else {
            fatalError("Logic error: tried to start showing pictures without an input path!")
        }
        let files = try! FileManager.default.contentsOfDirectory(at: inputPath, includingPropertiesForKeys: [URLResourceKey]())
        var imageFiles = [URL]()
        for file in files {
            if ViewController.isImage(file) {
                imageFiles.append(file)
            }
        }
        self.imageFiles = imageFiles
        currentImageIndex = 0
        showImage()
    }
    
    private func folderName(for event: NSEvent) -> String? {
        guard let chars = event.characters?.characters, chars.count == 1 else {
            return nil
        }
        let validNames = [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" ]
        let eventChar = String(chars[chars.index(chars.startIndex, offsetBy: 1)])
        guard validNames.contains(eventChar) else {
            return nil
        }
        return eventChar
    }
    
    private func copyFile(to folderName: String) {
        guard let inputPath = inputPath else {
            fatalError("Logic error: copyFile(to:) called with no input path set!")
        }
        let fullFolderPath = inputPath.appendingPathComponent(folderName, isDirectory: true)
        guard let imageFiles = imageFiles else {
            fatalError("Logic error: image files are not accessible!")
        }
        let fileURL = imageFiles[currentImageIndex]
        let fileName = fileURL.lastPathComponent
        let newURL = fullFolderPath.appendingPathComponent(fileName)
        
        try! FileManager.default.moveItem(at: fileURL, to: newURL)
        currentImageIndex += 1
        showImage()
    }
    
    private func showImage() {
        guard let imageFiles = imageFiles else {
            fatalError("Logic error: imageFiles is nil!")
        }
        if currentImageIndex >= imageFiles.count {
            print("All done!")
            imageViewPreview.image = nil
            return
        }
        imageViewPreview.image = NSImage(contentsOf: imageFiles[currentImageIndex])
    }
}

