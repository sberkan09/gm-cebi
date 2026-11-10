# GM Cebi — Privacy Policy

Effective date: <PUBLICATION DATE>
Developer: <NAME or PUBLISHER> · Contact: <EMAIL>

GM Cebi is an offline companion app for 5E compatible tabletop roleplaying games.
**The app does not collect personal data and does not send any data to us or to
third parties.**

## Data we collect

None. The app has:

- No internet connection. The Android app does not even request the internet
  permission (`android.permission.INTERNET`), and the iOS app contains no networking code.
- No ads, analytics, crash reporting, tracking or user accounts.
- No location, camera, microphone, contacts, photos or other device permissions.
- No in-app purchases or payments.

## Data stored on your device

The following is stored only on your device, in the app's private storage. It never
reaches us:

- **Settings:** theme, default content language.
- **Session notes:** the titles and text you write.
- **Encounters (initiative tracker):** the names, initiative, hit points, armor class and
  condition tags you enter.
- **Dice history** is kept in memory while the app is open and is not saved.

You can delete this data inside the app (delete a note, "New encounter"). Uninstalling
the app deletes all of it.

**Device backups:** if Android backup (backup to your Google account) or iCloud/computer
backup is turned on, the operating system may back up this data together with other app
data. Such backups are made by Google or Apple in your account. The developer has no
access to them.

## Online scene (optional)

<!-- Publish only for builds with the online scene enabled (docs/online-scene.md). If this section is
published, the "does not collect" sentence in the introduction and "Data we collect" must change
accordingly. -->

If you use "Sahneyi canlandır" (bring the scene to life) on the battle map, the terrain you drew is
sent to the NeuraCraft Cloud service to be turned into a picture. The feature is optional; if you do
not use it, nothing is sent and the app keeps working offline.

- **Sign-in:** the feature only works after you sign in with your email address (for this feature
  only). The address is used only to send a 6-digit sign-in code, sent by Brevo (EU). NeuraCraft does
  not store the address itself, only a keyed hash (HMAC) of it, a random user id and sign-up / last
  use times. No name or store account is asked for. The app keeps the address on your device only, to
  show it in Settings; the sign-in tokens are kept in the device's secure storage (Keychain, Android
  Keystore).
- **What is sent and how long it is kept:** the sketch for 24 hours, the generated picture for 7
  days, your description until 24 hours after the job finishes. Tokens and encounter details are not
  sent.
- **Where:** jobs run on servers in the European Union.
- **Sub-processors:** to translate your description into English, the text may be sent without any
  identifier to Anthropic (USA). Brevo (EU) sends the code emails.
- **Ads, analytics, tracking:** none. Data is not sold or shared for advertising.

### Deleting your account

Settings → Çevrimiçi sahne → **"Hesabımı sil"** (delete my account). Your account and all your data on
the server (sketches, pictures, descriptions, sign-in tokens) are deleted at once, and the online
pictures in the app too. "Çıkış yap" (sign out) only ends the sign-in on this device. If you cannot
use the app, send the deletion request to <EMAIL>.

## Third parties

The app contains no third-party libraries or services (SDKs) that send data. The store
you installed it from (Google Play, App Store) may collect installation and crash
statistics under its own policies; that data is governed by the store's privacy policy.

## Children

The app is not directed at children under 13 and collects no personal data from anyone.

## Changes

If a feature that processes data is added later (for example online backup or
purchases), this policy will be updated and published here before the app update, with
a new effective date.

## Contact

Questions: <EMAIL>

---

*This policy is based on a review of GM Cebi's source code: the runtime dependencies are
`flutter_riverpod`, `drift`, `drift_flutter`, `sqlite3` and `path_provider`, none of which opens a
network connection; `http` and `flutter_secure_storage` serve only the optional online scene and never
run in builds without it. The store build check (`tool/check_store_build.sh`)
verifies on every release that the Android build has no internet permission.*
