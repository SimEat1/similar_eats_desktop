param([string]$Proj = "C:\projects\similar_eats_desktop")
Set-Location $Proj
flutter pub get
flutter run -d chrome

