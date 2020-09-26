//
//  SettingsViewController.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var btnLaunchAtLogin: NSButton!
    @IBOutlet weak var btnEnableShortcut: NSButton!
    @IBOutlet weak var btnEnableMenuBarIcon: NSButton!
    @IBOutlet weak var btnEnableDeactivateKey: NSButton!
    @IBOutlet weak var btnShortcutDeactivateKey: NSPopUpButton!
    @IBOutlet weak var slider: NSSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer?.backgroundColor = NSColor.clear.cgColor

        btnLaunchAtLogin.state = NSApplication.shared.startAtLogin ? .on : .off

        btnEnableShortcut.state = defaults[.EnableShortcut] ? .on : .off

        btnEnableMenuBarIcon.state = defaults[.enableMenuBarIcon] ? .on : .off

        let isEnableDeactivateKey = defaults[.EnableDeactivateKey]

        btnEnableDeactivateKey.state = isEnableDeactivateKey ? .on : .off

        btnShortcutDeactivateKey.selectItem(at: defaults[.DeactivateKey])
        btnShortcutDeactivateKey.isEnabled = isEnableDeactivateKey

        slider.doubleValue = defaults[.DelayInterval]
        slider.isEnabled = isEnableDeactivateKey
    }

    @IBAction func toggleLaunchAtLogin(_ sender: Any) {
        NSApplication.shared.toggleStartAtLogin()
    }

    @IBAction func toggleEnableShortcut(_ sender: Any) {
        let enable = btnEnableShortcut.state == .on

        defaults[.EnableShortcut] = enable

        enable ? ShortcutMonitor.register() : ShortcutMonitor.unregister()
    }

    @IBAction func toggleEnableMenuBarIcon(_ sender: Any) {
        let enable = btnEnableMenuBarIcon.state == .on

        defaults[.enableMenuBarIcon] = enable

        if enable {
            sharedAppDelegate?.statusItemController.showInMenuBar()
        } else {
            sharedAppDelegate?.statusItemController.hideInMenuBar()
        }
    }

    @IBAction func toggleEnableDeactivateKey(_ sender: Any) {
        let isEnableDeactivateKey = btnEnableDeactivateKey.state == .on

        defaults[.EnableDeactivateKey] = isEnableDeactivateKey

        btnShortcutDeactivateKey.isEnabled = isEnableDeactivateKey
        slider.isEnabled = isEnableDeactivateKey
    }

    @IBAction func changeDeactivateKey(_ sender: Any) {
        defaults[.DeactivateKey] = btnShortcutDeactivateKey.indexOfSelectedItem
    }

    @IBAction func changeShortcutReactivateInterval(_ sender: Any) {
        defaults[.DelayInterval] = slider.doubleValue
    }

    @IBAction func exit(_ sender: Any) {
        NSApp.terminate(self)
    }

}
