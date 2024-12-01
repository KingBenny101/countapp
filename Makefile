RELEASE_FOLDER = release
ANDROID_BUILD = build\app\outputs\flutter-apk\app-release.apk
WINDOWS_BUILD = build\windows\x64\runner\Release\countapp.exe


all: generate flutter_launcher_icons clean_release build_android build_windows copy_files


generate:
	@echo Running package_rename...
	dart run package_rename
	@echo Running flutter_launcher_icons...
	dart run flutter_launcher_icons:main


clean_release:
	@del /q "$(RELEASE_FOLDER)\*" 2>nul || echo No files to clean in the releases folder.
	@mkdir "$(RELEASE_FOLDER)" 2>nul || echo Releases folder already exists.


build_android:
	@echo Building for Android...
	@flutter build apk --release


build_windows:
	@echo Building for Windows...
	@flutter build windows --release


copy_files:
	@if exist "$(ANDROID_BUILD)" (copy "$(ANDROID_BUILD)" "$(RELEASE_FOLDER)\" && echo APK file copied successfully.) || echo APK file not found at $(ANDROID_BUILD)
	@if exist "$(WINDOWS_BUILD)" (copy "$(WINDOWS_BUILD)" "$(RELEASE_FOLDER)\" && echo EXE file copied successfully.) || echo EXE file not found at $(WINDOWS_BUILD)

.PHONY: all generate flutter_launcher_icons clean_release build_android build_windows copy_files
