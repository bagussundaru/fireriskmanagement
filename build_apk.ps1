# Fire Risk Assessment Build Script

# 1. Setup Environment Variables
$env:JAVA_HOME = "C:\Java\jdk-17.0.2"
$env:ANDROID_HOME = "C:\Android"
$cmdlineToolsPath = "$env:ANDROID_HOME\cmdline-tools\cmdline-tools" 
# Note: Extract biasanya bikin folder cmdline-tools di dalam cmdline-tools, perlu dicek nanti

# Add to PATH temporarily for this session
$env:PATH = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools;$env:PATH"

Write-Host "Checking Java..."
java -version

# 2. Check Android Tools
if (-not (Test-Path "$env:ANDROID_HOME\cmdline-tools")) {
    Write-Error "Android Command-line Tools belum terinstall di $env:ANDROID_HOME"
    exit
}

# 3. Rename folder structure locally if needed (sdkmanager needs cmdline-tools/latest)
# Struktur yang benar: C:\Android\cmdline-tools\latest\bin
# Zip biasanya extract ke: C:\Android\cmdline-tools\cmdline-tools\*
if (Test-Path "$env:ANDROID_HOME\cmdline-tools\cmdline-tools") {
    Write-Host "Fixing folder structure..."
    Move-Item "$env:ANDROID_HOME\cmdline-tools\cmdline-tools" "$env:ANDROID_HOME\cmdline-tools\latest"
}

# 4. Install SDK Components
Write-Host "Installing Android SDK Components..."
yes | sdkmanager --sdk_root=$env:ANDROID_HOME "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# 5. Accept Licenses
Write-Host "Accepting Licenses..."
yes | flutter doctor --android-licenses

# 6. Configure Flutter
flutter config --android-sdk $env:ANDROID_HOME

# 7. Build APK
Write-Host "Building APK..."
flutter build apk --release

Write-Host "Build Complete! Check build/app/outputs/flutter-apk/app-release.apk"
