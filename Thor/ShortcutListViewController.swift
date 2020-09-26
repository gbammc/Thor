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

    private let dragDropType = NSPasteboard.PasteboardType(rawValue: "thor.drag-drop-app")

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!

    var observation: NSKeyValueObservation!

    var apps: [AppModel] {
        return AppsManager.manager.selectedApps
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer?.backgroundColor = NSColor.clear.cgColor

        tableView.registerForDraggedTypes([dragDropType])

        observation = AppsManager.manager.observe(\.selectedApps, changeHandler: { [unowned self] (_, _) in
            self.tableView.reloadData()
        })
    }

    @IBAction func add(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = [kUTTypeApplicationFile as String, kUTTypeApplicationBundle as String]
        if let appDir = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .localDomainMask, true).first {
            openPanel.directoryURL = URL(fileURLWithPath: appDir)
        }
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
        let identifier = NSUserInterfaceItemIdentifier(rawValue: shortcutTableCellViewIdentifier)
        let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? ShortcutTableCellView
        let app = apps[row]

        cell?.configure(app.appDisplayName, icon: app.icon, shortcut: app.shortcut) { (shortcut) in
            AppsManager.manager.save(app, shortcut: shortcut)
        }

        return cell
    }

    // MARK: Drag and Drop

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: dragDropType)
        return item
    }

    func tableView(_ tableView: NSTableView,
                   validateDrop info: NSDraggingInfo,
                   proposedRow row: Int,
                   proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {

        return dropOperation == .above ? .move : []
    }

    func tableView(_ tableView: NSTableView,
                   acceptDrop info: NSDraggingInfo,
                   row: Int,
                   dropOperation: NSTableView.DropOperation) -> Bool {

        guard let items = info.draggingPasteboard.pasteboardItems else { return false }

        let indexes = items.compactMap { Int($0.string(forType: dragDropType)!) }
        if !indexes.isEmpty {
            AppsManager.manager.move(with: indexes, to: row)

            var oldIndexOffset = 0
            var newIndexOffset = 0

            tableView.beginUpdates()
            for oldIndex in indexes {
                if oldIndex < row {
                    tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                    oldIndexOffset -= 1
                } else {
                    tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                    newIndexOffset += 1
                }
            }
            tableView.endUpdates()
        }

        return true
    }

}
