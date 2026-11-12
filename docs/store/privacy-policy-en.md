# GM Cebi — Privacy Policy

<!-- OWNER MUST FILL IN BEFORE PUBLISHING (this comment is not shown on the published page; do not
publish while any bracketed placeholder is left):
  - <PUBLICATION DATE>
  - <NAME or PUBLISHER>
  - <CONTACT AND DELETION EMAIL — OWNER TO FILL IN>: questions and (in an online scene build) account
    deletion requests from users who cannot use the app go here. Do not invent an address.
  - Online scene section: publish only if an online scene build goes to a store; then replace the
    introduction and "Data we collect" with the ready text in that section. -->

Effective date: <PUBLICATION DATE>
Developer: <NAME or PUBLISHER> · Contact: <CONTACT AND DELETION EMAIL — OWNER TO FILL IN>

GM Cebi is an offline companion app for 5E compatible tabletop roleplaying games.
**The app does not collect personal data and does not send any data to us or to
third parties.**

## Data we collect

None. The app has:

- No network requests. The store build connects to no server; the Android app does not even
  request the internet permission (`android.permission.INTERNET`). The code of the optional online
  feature is present in the app, but it is switched off at build time in this build: no server
  address is given, the feature is not shown and never runs.
- No ads, analytics, crash reporting, tracking or user accounts.
- No location, camera, microphone, contacts, photos or other device permissions.
- No in-app purchases or payments.

## Data stored on your device

The following is stored only on your device, in the app's private storage (backup files: wherever
you choose to save them). It never reaches us:

- **Settings:** theme, default content language.
- **Session notes:** the titles and text you write.
- **Encounters (initiative tracker):** the names, initiative, hit points, armor class, level and
  condition tags you enter.
- **Battle map:** the lines you draw, the areas you paint with the area brush and where the tokens
  are on the map, kept with the encounter.
- **Online pictures** (only in an online scene build, if you use the feature): the generated map
  pictures, the description you wrote and the picture's id on the server, kept with the encounter.
- **Backup files:** files you create yourself with Ayarlar → Yedekleme → "Yedek al" (Settings →
  Backup → make a backup). They hold a copy of your app data. They stay on your device unless you
  share them (for example by emailing them to yourself) and never reach us. A backup file never
  contains sign-in tokens.
- **Dice history** is kept in memory while the app is open and is not saved.

You can delete this data inside the app (delete a note, "New encounter"; the map and pictures are
deleted with their encounter). Uninstalling the app deletes all of it; backup files you created and
copied elsewhere are yours to delete.

**Device backups:** if Android backup (backup to your Google account) or iCloud/computer
backup is turned on, the operating system may back up this data together with other app
data. Such backups are made by Google or Apple in your account. The developer has no
access to them.

## Online scene (optional)

<!-- Publish only for builds with the online scene enabled (docs/online-scene.md). If this section is
published, replace the introduction and the first item of "Data we collect" with this ready text:

  Introduction:
  GM Cebi is an offline companion app for 5E compatible tabletop roleplaying games. **Apart from the
  optional "bring the scene to life" feature, the app does not send any data to us or to third
  parties.** That feature sends your battle map sketch and the description you write to a server to
  make a picture, and only after you agree and sign in with a code sent to your email (see "Online
  scene" below).

  "Data we collect" heading and first item:
  ## Data we collect
  Only if you use the optional online scene: what "Online scene" below describes. Otherwise the app has:
  - No network requests. The app connects to no server unless you use the online scene.
  (The other items stay as they are.) -->

If you use "Sahneyi canlandır" (bring the scene to life) on the battle map, the terrain you drew is
sent to the NeuraCraft Cloud service to be turned into a picture. The feature is optional; if you do
not use it, nothing is sent and the app keeps working offline.

- **Sign-in:** the feature only works after you sign in with your email address (for this feature
  only). The address is used only to send a 6-digit sign-in code, sent by Brevo (EU). NeuraCraft does
  not store the address itself, only a keyed hash (HMAC) of it, a random user id and sign-up / last
  use times. No name or store account is asked for. The app keeps the address on your device only, to
  show it in Settings; the sign-in tokens are kept in the device's secure storage (Keychain, Android
  Keystore).
- **What is sent and how long it is kept:** the sketch (and, where the service supports it, the
  areas you painted with the area brush, as a separate image) for 24 hours, the generated picture for
  7 days, your description until 24 hours after the job finishes. Tokens and encounter details are
  not sent.
- **If you report a picture:** the picture's id is sent with the reason you pick (for example sexual
  content, violence, hate, child safety, other) and, if you write one, a note of up to 500 characters.
  The picture is hidden for review; do not put personal information in the note.
- **Where:** jobs run on servers in the European Union.
- **Sub-processors:** to translate your description into English, the text may be sent without any
  identifier to Anthropic (USA). Brevo (EU) sends the code emails.
- **Ads, analytics, tracking:** none. Data is not sold or shared for advertising.

### Deleting your account

Settings → Çevrimiçi sahne → **"Hesabımı sil"** (delete my account). Your account and all your data on
the server (sketches, pictures, descriptions, sign-in tokens) are deleted at once, and the online
pictures in the app too. "Çıkış yap" (sign out) only ends the sign-in on this device. If you cannot
use the app, send the deletion request to <CONTACT AND DELETION EMAIL — OWNER TO FILL IN>.

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

Questions: <CONTACT AND DELETION EMAIL — OWNER TO FILL IN>

---

*This policy is based on a review of GM Cebi's source code: the runtime dependencies are
`flutter_riverpod`, `drift`, `drift_flutter`, `sqlite3` and `path_provider`, none of which opens a
network connection; `http` and `flutter_secure_storage` serve only the optional online scene and never
run in builds without it (their code is compiled in, but with no server address no request is made). The store build check (`tool/check_store_build.sh`)
verifies on every release that the Android build has no internet permission.*
