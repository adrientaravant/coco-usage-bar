import AppKit
import Sparkle

@MainActor
final class UpdaterController: NSObject, SPUUpdaterDelegate {
    static let shared = UpdaterController()
    static let stateDidChangeNotification = Notification.Name("CocoUsageBarUpdaterStateDidChange")

    private var controller: SPUStandardUpdaterController?
    private var availableVersion: String?
    private var isChecking = false
    private var lastInformationCheckAt: Date?

    private override init() {
        super.init()
    }

    func start() {
        guard controller == nil else { return }
        let controller = SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
        controller.startUpdater()
        self.controller = controller
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.refreshUpdateInformationIfStale(maxAge: 0)
        }
    }

    var menuTitle: String {
        if availableVersion != nil {
            return "Update ready, sync?"
        }
        if isChecking {
            return "Checking for Updates..."
        }
        return "Check for Updates..."
    }

    var canCheckForUpdates: Bool {
        controller?.updater.canCheckForUpdates ?? false
    }

    @objc func checkForUpdates(_ sender: Any?) {
        setChecking(true)
        lastInformationCheckAt = Date()
        controller?.checkForUpdates(sender)
    }

    func refreshUpdateInformationIfStale(maxAge: TimeInterval = 5 * 60) {
        guard availableVersion == nil, !isChecking else { return }
        if let lastInformationCheckAt, Date().timeIntervalSince(lastInformationCheckAt) < maxAge {
            return
        }
        checkForUpdateInformation()
    }

    private func checkForUpdateInformation() {
        guard let updater = controller?.updater, updater.canCheckForUpdates else { return }
        lastInformationCheckAt = Date()
        setChecking(true)
        updater.checkForUpdateInformation()
    }

    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        setAvailableVersion(item.displayVersionString)
    }

    func updaterDidNotFindUpdate(_ updater: SPUUpdater, error: Error) {
        setAvailableVersion(nil)
    }

    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        setChecking(false)
    }

    func updater(_ updater: SPUUpdater, didFinishUpdateCycleFor updateCheck: SPUUpdateCheck, error: Error?) {
        setChecking(false)
    }

    private func setAvailableVersion(_ version: String?) {
        guard availableVersion != version || isChecking else { return }
        availableVersion = version
        isChecking = false
        notifyStateDidChange()
    }

    private func setChecking(_ checking: Bool) {
        guard isChecking != checking else { return }
        isChecking = checking
        notifyStateDidChange()
    }

    private func notifyStateDidChange() {
        NotificationCenter.default.post(name: Self.stateDidChangeNotification, object: self)
    }
}
