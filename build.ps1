$RELEASE_FOLDER = "release"
$APP_NAME = "countapp"
$ANDROID_BUILD = "build\app\outputs\flutter-apk\app-release.apk"
$WINDOWS_BUILD = "build\windows\x64\runner\Release\countapp.msix"

$MANIFEST_PATH = "android\app\src\main\AndroidManifest.xml"
$PERMISSIONS = @"
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
"@

$VERSION = ""

function GetVersion {
    $pubspecContent = Get-Content "pubspec.yaml"
    foreach ($line in $pubspecContent) {
        if ($line -match '^version:\s*(\S+)') {
            ${global:VERSION}  = $Matches[1]
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
    Write-Host "`nInstalling dependencies..."
    flutter pub get
    Write-Host "`nCreating Android platform..."
    flutter create --platforms=android --android-language=java .
    Write-Host "`nAdding Permissions..."

    (Get-Content $MANIFEST_PATH) | ForEach-Object {
        if ($_ -match "</manifest>") {
            $PERMISSIONS
        }
        $_
    } | Set-Content $MANIFEST_PATH


    Write-Host "`nCreating Windows platform..."
    flutter create --platforms=windows .
    Write-Host "`nRemoving Test folder..."
    Remove-Item "test" -Force -Recurse -ErrorAction SilentlyContinue 
    Write-Host "`nRunning package_rename..."
    dart run package_rename
    Write-Host "`nRunning flutter_launcher_icons..."
    dart run flutter_launcher_icons:main
}

function CleanEnvironment {
    if (Test-Path $RELEASE_FOLDER) {
        Remove-Item "$RELEASE_FOLDER\*" -Force -ErrorAction SilentlyContinue
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
    dart run msix:create

    if (Test-Path $WINDOWS_BUILD) {
        Copy-Item $WINDOWS_BUILD -Destination $RELEASE_FOLDER
        Write-Host "`nEXE file copied successfully."

        $msixPath = Join-Path $RELEASE_FOLDER (Split-Path $WINDOWS_BUILD -Leaf)
        $newMsixName = "$APP_NAME-${global:VERSION}.msix"
        Rename-Item -Path $msixPath -NewName $newMsixName
        Write-Host "`nMSIX file renamed to $newMsixName."
    }
    else {
        Write-Host "`nEXE file not found at $WINDOWS_BUILD"
    }
}

function All {
    GetVersion
    GenerateEnvironment
    CleanEnvironment
    BuildAndroid
    BuildWindows
}

$task = $args[0] 

switch ($task) {
    "generate" { GenerateEnvironment }
    "clean" { CleanRelease }
    "build_android" { BuildAndroid }
    "build_windows" { BuildWindows }
    "all" { All }
    default { Write-Host "Invalid task. Available tasks: generate, clean, build_android, build_windows, all" }
}
