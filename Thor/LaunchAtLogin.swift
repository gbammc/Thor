import Foundation
import OSLog
import ServiceManagement

enum LaunchAtLogin {
    private static let mainApp = SMAppService.mainApp
    private static let helperIdentifier = (Bundle.main.bundleIdentifier ?? "me.alvinzhu.Thor") + "-LaunchAtLoginHelper"
    private static let helper = SMAppService.loginItem(identifier: helperIdentifier)

    static var isEnabled: Bool {
        mainApp.status == .enabled || legacyIsEnabled
    }

    static func setEnabled(_ enabled: Bool) {
        defaults[.LaunchAtLoginKey] = enabled
        migrateIfNeeded()
    }

    static func migrateIfNeeded() {
        let savedPreference = defaults.object(forKey: DefaultsKeys.LaunchAtLoginKey.key) as? Bool
        guard savedPreference != nil || !defaults[.LaunchAtLoginMigrationCompleted] else { return }

        guard let enabled = savedPreference ?? (legacyIsEnabled ? true : nil) else {
            defaults[.LaunchAtLoginMigrationCompleted] = true
            return
        }
        defaults[.LaunchAtLoginKey] = enabled

        do {
            if enabled {
                if !isRegistered(mainApp) { try mainApp.register() }
                // Keep a working helper while the system still needs approval for the main app.
                guard mainApp.status == .enabled else { return }
            } else if isRegistered(mainApp) {
                try mainApp.unregister()
            }

            guard disableLegacyHelper() else { return }
            defaults.removeObject(forKey: DefaultsKeys.LaunchAtLoginKey.key)
            defaults[.LaunchAtLoginMigrationCompleted] = true
        } catch {
            Logger.app.error("Could not update launch at login: \(error.localizedDescription)")
        }
    }

    private static func isRegistered(_ service: SMAppService) -> Bool {
        let status = service.status
        return status == .enabled || status == .requiresApproval
    }

    private static var legacyIsEnabled: Bool {
        let status = helper.status
        if status == .enabled { return true }
        if status == .requiresApproval { return false }
        let jobs = legacyAPI.jobs
        return jobs?.contains { job in
            job["Label"] as? String == helperIdentifier && job["OnDemand"] as? Bool == true
        } ?? false
    }

    private static func disableLegacyHelper() -> Bool {
        if isRegistered(helper) {
            do {
                try helper.unregister()
            } catch {
                Logger.app.error("Could not unregister login helper: \(error.localizedDescription)")
            }
        }
        guard legacyIsEnabled || isRegistered(helper) else { return true }
        guard legacyAPI.disable(helperIdentifier) else {
            Logger.app.error("Could not disable the legacy login helper")
            return false
        }
        return !legacyIsEnabled && !isRegistered(helper)
    }

    private static var legacyAPI: LegacyLoginItemAPI.Type { LaunchAtLogin.self }
}

private protocol LegacyLoginItemAPI {
    static var jobs: [[String: AnyObject]]? { get }
    static func disable(_ identifier: String) -> Bool
}

extension LaunchAtLogin: LegacyLoginItemAPI {
    @available(*, deprecated)
    fileprivate static var jobs: [[String: AnyObject]]? {
        SMCopyAllJobDictionaries(kSMDomainUserLaunchd)?.takeRetainedValue() as? [[String: AnyObject]]
    }

    @available(*, deprecated)
    fileprivate static func disable(_ identifier: String) -> Bool {
        SMLoginItemSetEnabled(identifier as CFString, false)
    }
}
