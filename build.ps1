$RELEASE_FOLDER = "release"
$ANDROID_BUILD = "build\app\outputs\flutter-apk\app-release.apk"
$WINDOWS_BUILD = "build\windows\x64\runner\Release\countapp.msix"


function CreatePlatform {
    Write-Host "`nCreating Android platform..."
    flutter create --platforms=android --android-language=java .
    Write-Host "`nCreating Windows platform..."
    flutter create --platforms=windows .
    Write-Host "`nRemoving Test folder..."
    Remove-Item "test" -Force -Recurse -ErrorAction SilentlyContinue 
   
}

function Generate {
    Write-Host "`nRunning package_rename..."
    dart run package_rename
    Write-Host "`nRunning flutter_launcher_icons..."
    dart run flutter_launcher_icons:main
}

function CleanRelease {
    if (Test-Path $RELEASE_FOLDER) {
        Remove-Item "$RELEASE_FOLDER\*" -Force -ErrorAction SilentlyContinue
        Write-Host "`nCleaned release folder."
    } else {
        New-Item -ItemType Directory -Path $RELEASE_FOLDER | Out-Null
        Write-Host "`nCreated release folder."
    }
}

function BuildAndroid {
    Write-Host "`nBuilding for Android..."
    flutter build apk --release
}

function BuildWindows {
    Write-Host "`nBuilding for Windows..."
    dart run msix:create
}

function CopyFiles {
    if (Test-Path $ANDROID_BUILD) {
        Copy-Item $ANDROID_BUILD -Destination $RELEASE_FOLDER
        Write-Host "`nAPK file copied successfully."
    } else {
        Write-Host "`nAPK file not found at $ANDROID_BUILD"
    }

    if (Test-Path $WINDOWS_BUILD) {
        Copy-Item $WINDOWS_BUILD -Destination $RELEASE_FOLDER
        Write-Host "`nEXE file copied successfully."
    } else {
        Write-Host "`nEXE file not found at $WINDOWS_BUILD"
    }
}

function All {
    CreatePlatform
    Generate
    CleanRelease
    BuildAndroid
    BuildWindows
    CopyFiles
}

$task = $args[0] 

switch ($task) {
    "create_platform" { CreatePlatform }
    "generate" { Generate }
    "clean_release" { CleanRelease }
    "build_android" { BuildAndroid }
    "build_windows" { BuildWindows }
    "copy_files" { CopyFiles }
    "all" { All }
    default { Write-Host "Invalid task. Available tasks: create_platform, generate, clean_release, build_android, build_windows, copy_files, all" }
}
