$generateScriptPath = "generate.ps1"
$releaseFolderPath = "release"

if (Test-Path $generateScriptPath) {
    # Run the other script
    Write-Host "Running generate script..."
    & $generateScriptPath
} else {
    Write-Host "Generate scipt not found, skipping..."
}


if (Test-Path $releaseFolderPath) {
    Write-Host "Releases folder exists. Removing all files inside..."
    
    Get-ChildItem -Path $releaseFolderPath -File | Remove-Item -Force
    Write-Host "All files removed from the releases folder."
} else {
    Write-Host "Releases folder does not exist. Creating folder..."
    
    New-Item -Path $releaseFolderPath -ItemType Directory
    Write-Host "Releases folder created."
}

Write-Host "Building for Android..."
flutter build apk --release

Write-Host "Building for Windows..."
flutter build windows --release


$androidFilePath = "build\app\outputs\flutter-apk\app-release.apk"
$windowsFilePath = "build\windows\x64\runner\Release\countappdev.exe"

if (Test-Path $androidFilePath) {
    Copy-Item -Path $androidFilePath -Destination $releaseFolderPath -Force
    Write-Host "APK file copied successfully."
} else {
    Write-Host "APK file not found at $androidFilePath"
}

if (Test-Path $windowsFilePath) {
    Copy-Item -Path $windowsFilePath -Destination $releaseFolderPath -Force
    Write-Host "EXE file copied successfully."
} else {
    Write-Host "EXE file not found at $windowsFilePath"
}
