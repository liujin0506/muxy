import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(UpdateChannel.storageKey)
    private var updateChannelRaw = UpdateChannel.stable.rawValue
    @AppStorage(QuitConfirmationPreferences.confirmQuitKey)
    private var confirmQuit = true
    @AppStorage(AppLanguagePreference.storageKey)
    private var storedLanguageRaw = AppLanguage.system.rawValue
    @State private var pendingLanguage: AppLanguage?
    @State private var sentry = SentryService.shared

    var body: some View {
        SettingsContainer {
            SettingsSection(
                "Language",
                footer: "Muxy restarts to apply a new language."
            ) {
                SettingsRow("Display Language") {
                    Picker("", selection: languageBinding) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .labelsHidden()
                    .frame(width: SettingsMetrics.controlWidth, alignment: .trailing)
                }
            }

            SettingsSection(
                "Updates",
                footer: "The Beta channel ships every change merged to main and may be unstable. "
                    + "Switch back to Stable to receive only tagged releases."
            ) {
                SettingsRow("Update channel") {
                    Picker("", selection: channelBinding) {
                        ForEach(UpdateChannel.allCases) { channel in
                            Text(channel.displayName).tag(channel)
                        }
                    }
                    .labelsHidden()
                    .frame(width: SettingsMetrics.controlWidth, alignment: .trailing)
                }
            }

            SettingsSection("Quit", showsDivider: sentry.hasDSN) {
                SettingsToggleRow(
                    label: "Confirm before quitting Muxy",
                    isOn: $confirmQuit
                )
            }

            if sentry.hasDSN {
                SettingsSection(
                    "Diagnostics",
                    footer: "Anonymous crash reports help us fix bugs. "
                        + "Reports never include project paths, file contents, or personal data.",
                    showsDivider: false
                ) {
                    SettingsToggleRow(
                        label: "Send anonymous crash reports",
                        isOn: sentryConsentBinding
                    )
                }
            }
        }
        .alert("Restart Muxy?".localized, isPresented: restartConfirmationBinding) {
            Button("Restart".localized, action: applyPendingLanguage)
            Button("Cancel".localized, role: .cancel) { pendingLanguage = nil }
        } message: {
            Text("Muxy needs to restart to change the display language.".localized)
        }
    }

    private var storedLanguage: AppLanguage {
        AppLanguage(rawValue: storedLanguageRaw) ?? .system
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { pendingLanguage ?? storedLanguage },
            set: { pendingLanguage = ($0 == storedLanguage) ? nil : $0 }
        )
    }

    private var restartConfirmationBinding: Binding<Bool> {
        Binding(
            get: { pendingLanguage != nil },
            set: { if !$0 { pendingLanguage = nil } }
        )
    }

    private func applyPendingLanguage() {
        guard let language = pendingLanguage else { return }
        pendingLanguage = nil
        AppLanguagePreference.apply(language)
        try? AppRelaunch.relaunch()
    }

    private var sentryConsentBinding: Binding<Bool> {
        Binding(
            get: { sentry.consent == .allowed },
            set: { newValue in sentry.setConsent(newValue ? .allowed : .denied) }
        )
    }

    private var channelBinding: Binding<UpdateChannel> {
        Binding(
            get: { UpdateChannel(rawValue: updateChannelRaw) ?? .stable },
            set: { newValue in
                updateChannelRaw = newValue.rawValue
                UpdateService.shared.channel = newValue
            }
        )
    }
}
