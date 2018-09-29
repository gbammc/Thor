//
//  ShortcutListViewController.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

class ShortcutListViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    var apps: [AppModel] { get { return AppsManager.manager.selectedApps } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBackgroundColor()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        updateBackgroundColor()
    }
    
    private func updateBackgroundColor() {
        // FIXME: Color Set not work
        // Here is a patch
        if #available(OSX 10.14, *) {
            let appearanceName = view.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua])
            if let appearanceName = appearanceName, appearanceName == .darkAqua {
                view.layer?.backgroundColor = NSColor(red: 0.196, green: 0.196, blue: 0.196, alpha: 1).cgColor
            } else {
                view.layer?.backgroundColor = NSColor.white.cgColor
            }
        } else {
            view.layer?.backgroundColor = NSColor.white.cgColor
        }
    }
    
    @IBAction func add(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = [kUTTypeApplicationFile as String, kUTTypeApplicationBundle as String]
        
        openPanel.beginSheetModal(for: view.window!, completionHandler: { (result) in
            if result == NSApplication.ModalResponse.OK, let metaDataItem = NSMetadataItem(url: openPanel.urls.first!) {
                let app = AppModel(item: metaDataItem)
                
                AppsManager.manager.save(app, shortcut: nil)
                
                self.tableView.reloadData()
                self.tableView.scrollRowToVisible(self.apps.count - 1)
            }
        })
    }
    
    @IBAction func remove(_ sender: AnyObject) {
        guard tableView.selectedRow != -1 else { return }
        
        let alert = NSAlert()
        alert.addButton(withTitle: "Sure".localized())
        alert.addButton(withTitle: "Cancel".localized())
        alert.messageText = "Delete this shortcut?".localized()
        alert.alertStyle = .warning
        
        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            AppsManager.manager.delete(tableView.selectedRow)
            
            tableView.reloadData()
        }
    }

}

extension ShortcutListViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return apps.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return apps[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let app = apps[row]
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: shortcutTableCellViewIdentifier), owner: self) as! ShortcutTableCellView
        cell.configure(app.appDisplayName, icon: app.icon, shortcut: app.shortcut) { (shortcut) in
            AppsManager.manager.save(app, shortcut: shortcut)
        }
        
        return cell
    }
    
}
