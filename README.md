# My NFL Update app

My personal NFL news app.

## Develop

* Run `dart run build_runner build --delete-conflicting-outputs` to generate
  Dart code
* Run `flutter pub run flutter_launcher_icons:main` to generate app icons

## TODOs

* Implement getting all weeks with games
* Implement showing game info
* If the season did not start, add first game date to the message
  * Make "no season yet" message italic and centered
* Implement week updates in cache
  * If updated, set `hasUpdate`
* Add theme (make current constants proper theme)
  * Change colors to something cozy
  * Add text sizes
  * Style season view

### Nice to have

* Embed Youtube videos (not only search on Youtube)
* Generate standings in app

### Not really relevant for me but nice to have

* Add favorite team to settings (currently only SEA)
  * Use team in settings to get relevant game
* Fetch teams and make team selectable
  * Get division for standings based on team
