$srcBase = "d:\Programs\Flutter\Projects\SE101-COmmissary\lib\screens"
$dstBase = "d:\Programs\Flutter\Projects\SE_101\lib\screen\commissary"

$files = Get-ChildItem -Path $srcBase -Recurse -File -Filter "*.dart" | Where-Object {
    $relPath = $_.FullName.Substring($srcBase.Length + 1)
    (-not $relPath.StartsWith("auth")) -and ($_.Name -ne "commissary_page")
}

foreach ($f in $files) {
    $rel = $f.FullName.Substring($srcBase.Length + 1)
    $targetRel = $rel
    
    # Handle home_screen -> commissary_home_screen renaming
    if ($rel -match "^home\\home_screen") {
        $targetRel = $targetRel -replace "home_screen", "commissary_home_screen"
    }
    
    $targetPath = Join-Path $dstBase $targetRel
    
    # Ensure target directory exists
    $dir = Split-Path $targetPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    
    # Read content
    $content = Get-Content $f.FullName -Raw
    
    # === IMPORT TRANSFORMS (2-level deep) ===
    $content = $content -replace "import '../../app_globals\.dart'", "import 'package:chickenjoo_inventory/app_globals.dart'"
    $content = $content -replace "import '../../database/", "import 'package:chickenjoo_inventory/database/"
    $content = $content -replace "import '../../services/", "import 'package:chickenjoo_inventory/services/"
    $content = $content -replace "import '../../utils/design_constants\.dart'", "import 'package:chickenjoo_inventory/design_constants.dart'"
    $content = $content -replace "import '../../utils/", "import 'package:chickenjoo_inventory/utils/"
    $content = $content -replace "import '../../widgets/connection_status_indicator\.dart'", "import 'package:chickenjoo_inventory/connection_status_indicator.dart'"
    $content = $content -replace "import '../../widgets/", "import 'package:chickenjoo_inventory/widgets/"
    
    # === IMPORT TRANSFORMS (3-level deep) ===
    $content = $content -replace "import '../../../utils/design_constants\.dart'", "import 'package:chickenjoo_inventory/design_constants.dart'"
    $content = $content -replace "import '../../../database/", "import 'package:chickenjoo_inventory/database/"
    $content = $content -replace "import '../../../app_globals\.dart'", "import 'package:chickenjoo_inventory/app_globals.dart'"
    $content = $content -replace "import '../../../utils/", "import 'package:chickenjoo_inventory/utils/"
    $content = $content -replace "import '../../../services/", "import 'package:chickenjoo_inventory/services/"
    $content = $content -replace "import '../../../widgets/", "import 'package:chickenjoo_inventory/widgets/"
    
    # Package name fix
    $content = $content -replace "package:commissary_app/", "package:chickenjoo_inventory/"
    
    # === HOME SCREEN CLASS RENAMING ===
    if ($rel -match "^home\\") {
        $content = $content -replace "HomeScreenState", "CommissaryHomeScreenState"
        $content = $content -replace "HomeScreenController", "CommissaryHomeScreenController"
        $content = $content -replace "HomeScreenDesktop", "CommissaryHomeScreenDesktop"
        $content = $content -replace "HomeScreenMobile", "CommissaryHomeScreenMobile"
        $content = $content -replace "\bHomeScreen\b", "CommissaryHomeScreen"
        $content = $content -replace "import 'home_screen_mobile\.dart'", "import 'commissary_home_screen_mobile.dart'"
        $content = $content -replace "import 'home_screen_desktop\.dart'", "import 'commissary_home_screen_desktop.dart'"
        $content = $content -replace "import 'home_screen_controller\.dart'", "import 'commissary_home_screen_controller.dart'"
        $content = $content -replace "import 'home_screen\.dart'", "import 'commissary_home_screen.dart'"
    }
    
    # Write transformed content
    [System.IO.File]::WriteAllText($targetPath, $content)
    Write-Host "OK: $rel -> $targetRel"
}
Write-Host "`nTotal: $($files.Count) files"
