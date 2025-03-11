$RELEASE_FOLDER = "release"
$APP_NAME = "countapp"
$ANDROID_BUILD = "build\app\outputs\flutter-apk\app-release.apk"
$WINDOWS_BUILD = "build\windows\x64\runner\Release\*"

$VERSION = ""

function GetVersion {
    $pubspecContent = Get-Content "pubspec.yaml"
    foreach ($line in $pubspecContent) {
        if ($line -match '^version:\s*(\S+)') {
            ${global:VERSION} = $Matches[1]
            break
        }
    }

    if ([string]::IsNullOrEmpty(${global:VERSION})) {
        Write-Host "Version not found in pubspec.yml"
        return
    }
    Write-Host "Extracted version: ${global:VERSION}"
}

function GenerateEnvironment {
    Write-Host "`nRunning package_rename..."
    dart run package_rename
    Write-Host "`nRunning flutter_launcher_icons..."
    dart run flutter_launcher_icons:main
}

function CleanEnvironment {
    Write-Host "`nCleaning up previous builds..."
    flutter clean

    if (Test-Path $RELEASE_FOLDER) {
        Remove-Item "$RELEASE_FOLDER\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "`nCleaned release folder."
    }
    else {
        New-Item -ItemType Directory -Path $RELEASE_FOLDER | Out-Null
        Write-Host "`nCreated release folder."
    }
}

function BuildAndroid {
    Write-Host "`nBuilding for Android..."
    flutter build apk --release

    if (Test-Path $ANDROID_BUILD) {
        Copy-Item $ANDROID_BUILD -Destination $RELEASE_FOLDER
        Write-Host "`nAPK file copied successfully."

        $apkPath = Join-Path $RELEASE_FOLDER (Split-Path $ANDROID_BUILD -Leaf)
        $newApkName = "$APP_NAME-${global:VERSION}.apk"
        Rename-Item -Path $apkPath -NewName $newApkName
        Write-Host "`nAPK file renamed to $newApkName."
    }
    else {
        Write-Host "`nAPK file not found at $ANDROID_BUILD"
    }
}

function BuildWindows {
    Write-Host "`nBuilding for Windows..."
    flutter build windows --release

    try {
        Copy-Item -Path $WINDOWS_BUILD -Destination "$RELEASE_FOLDER\windows" -Recurse -Force
        Write-Host "`nWindows build copied successfully."
    }
    catch {
        Write-Host "`nError copying Windows build."
    }
}

function All {
    GetVersion
    CleanEnvironment
    BuildAndroid
    BuildWindows
}

$task = $args[0] 

switch ($task) {
    "clean" { CleanEnvironment }
    "generate" { GenerateEnvironment }
    "build_android" { BuildAndroid }
    "build_windows" { BuildWindows }
    "all" { All }
    default { Write-Host "Invalid task. Available tasks: clean, generate, build_android, build_windows, all" }
}
