//
//  ShortcutListViewController.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut
import UniformTypeIdentifiers

class ShortcutListViewController: NSViewController, NSMenuItemValidation {

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

        let menu = NSMenu()
        let locateItem = menu.addItem(withTitle: "Locate Application…".localized(),
                                      action: #selector(locateApplication(_:)), keyEquivalent: "")
        locateItem.target = self
        tableView.menu = menu

        observation = AppsManager.manager.observe(\.selectedApps, changeHandler: { [unowned self] (_, _) in
            self.tableView.reloadData()
        })
    }

    @IBAction func add(_ sender: AnyObject) {
        chooseApplication { app in
            let row = try AppsManager.manager.add(app)
            self.tableView.scrollRowToVisible(row)
        }
    }

    @objc private func locateApplication(_ sender: NSMenuItem) {
        let row = tableView.clickedRow >= 0 ? tableView.clickedRow : tableView.selectedRow
        guard apps.indices.contains(row) else { return }
        let app = apps[row]
        chooseApplication { replacement in
            try AppsManager.manager.relocate(app, to: replacement)
        }
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        tableView.clickedRow >= 0 || tableView.selectedRow >= 0
    }

    private func chooseApplication(_ action: @escaping (AppModel) throws -> Void) {
        guard let window = view.window else { return }
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [.applicationBundle]
        if let appDir = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .localDomainMask, true).first {
            openPanel.directoryURL = URL(fileURLWithPath: appDir)
        }
        openPanel.beginSheetModal(for: window) { result in
            guard result == .OK, let url = openPanel.url else { return }
            do {
                guard let app = AppModel(selectedURL: url) else { throw CocoaError(.fileReadCorruptFile) }
                try action(app)
            } catch {
                NSApp.presentError(error)
            }
        }
    }

    @IBAction func remove(_ sender: AnyObject) {
        guard tableView.selectedRow != -1 else { return }

        let alert = NSAlert()
        alert.addButton(withTitle: "Sure".localized())
        alert.addButton(withTitle: "Cancel".localized())
        alert.messageText = "Delete this shortcut?".localized()
        alert.alertStyle = .warning

        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            do {
                try AppsManager.manager.delete(tableView.selectedRow)
            } catch {
                presentError(error)
            }
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
            do {
                try AppsManager.manager.setShortcut(shortcut, for: app)
            } catch {
                tableView.reloadData()
                self.presentError(error)
            }
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

        let indexes = items.compactMap { $0.string(forType: dragDropType).flatMap(Int.init) }
        guard !indexes.isEmpty else { return false }
        do {
            try AppsManager.manager.move(with: indexes, to: row)
            return true
        } catch {
            presentError(error)
            return false
        }
    }

}
