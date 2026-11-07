# Picker

Can't decide? Type your choices, spin the wheel, and let it pick for you.

[Get it on Google Play](https://play.google.com/store/apps/details?id=com.Zcreations.pickerv2)

## Features

- Add as many choices as you like (blank ones are rejected, spaces trimmed).
- Tap **Roll** or swipe the wheel to spin it; the pick shows under the wheel.
- Lists you roll are saved automatically; tap the bookmark to save one
  without rolling. Open the **Saved** tab (bottom bar) to load a list again.
- Press and hold a choice to select it, then delete it with the trash icon.
  Back clears the selection.
- The **?** button explains how each screen works.

## How it works

- `lib/screens/home_screen.dart`: the choice list, selection mode and Roll.
- `lib/screens/picker_screen.dart`: the wheel (`flutter_fortune_wheel`), with
  labels laid out upright for where the wheel stops.
- `lib/screens/app_shell.dart`: the bottom bar switching Choices and Saved.
- `lib/screens/saved_choices.dart`: saved lists, stored in SQLite (`sqflite`).
  Choices that contain a comma are stored as JSON so they load back intact.

## Run it

```bash
flutter pub get
flutter run
flutter test
```

Android builds need JDK 17. If Flutter picks a newer JDK that Gradle can't
run, build through Gradle with `JAVA_HOME` pointing at JDK 17.

## Releasing

Every push to `master` is a Google Play **production** release
(`.github/workflows/deploy.yml`). To release:

1. Bump `version:` in `pubspec.yaml`. The build number after `+` must increase.
2. Add a `CHANGELOG.md` entry written for users (500 characters max). It
   becomes the Play "What's new" text.
3. Merge to `master` in one push.
