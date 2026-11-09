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

*This policy is based on a review of GM Cebi's source code: the only runtime dependencies
are `flutter_riverpod`, `drift`, `drift_flutter`, `sqlite3` and `path_provider`, none of
which opens a network connection. The store build check (`tool/check_store_build.sh`)
verifies on every release that the Android build has no internet permission.*
