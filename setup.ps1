$ErrorActionPreference = 'Stop'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host 'Flutter was not found in PATH.' -ForegroundColor Yellow
    Write-Host 'Install Flutter SDK: https://docs.flutter.dev/get-started/install/windows/mobile'
    Write-Host 'Then restart the terminal and run: .\setup.ps1'
    exit 1
}

if (-not (Test-Path -LiteralPath '.\android')) {
    flutter create --platforms=android --org com.timeprice .
}

flutter pub get
flutter doctor

Write-Host ''
Write-Host 'Ready. Start the app with: flutter run' -ForegroundColor Green
