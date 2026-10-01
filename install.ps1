#Requires -Version 5.0
<#
.SYNOPSIS
    Installs Elvish syntax highlighting support for Notepad++

.DESCRIPTION
    This script installs the Elvish User Defined Language (UDL) files for Notepad++:
    - UDL file (syntax highlighting) to userDefineLangs folder
    - AutoCompletion file to autoCompletion folder
    - FunctionList file to functionList folder and updates overrideMap.xml

.PARAMETER NotepadPlusPlusPath
    Optional. Specifies the Notepad++ installation directory.
    If not provided, the script attempts to auto-detect from Program Files.

.PARAMETER Help
    Display help information.

.EXAMPLE
    .\install.ps1
    Installs Elvish support with auto-detected Notepad++ location.

.EXAMPLE
    .\install.ps1 -NotepadPlusPlusPath "C:\Program Files\Notepad++"
    Installs Elvish support to a specific Notepad++ directory.

.EXAMPLE
    .\install.ps1 -Help
    Displays this help message.
#>

param(
    [string]$NotepadPlusPlusPath = "",
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Help {
    Write-Host @"
Elvish Notepad++ UDL Installer for Windows

SYNOPSIS
    Installs Elvish syntax highlighting support for Notepad++

USAGE
    .\install.ps1 [OPTIONS]

OPTIONS
    -NotepadPlusPlusPath <path>
        Specify the Notepad++ installation directory (optional).
        If not provided, the script will attempt to auto-detect.

    -Help
        Display this help message.

DESCRIPTION
    This script installs three components:
    1. UDL file - Syntax highlighting definition
    2. AutoCompletion file - Word list for autocompletion
    3. FunctionList file - Function parser definition with overrideMap.xml update

    Installation locations:
    - UDL: %APPDATA%\Notepad++\userDefineLangs\
    - AutoCompletion: [Notepad++ install dir]\autoCompletion\
    - FunctionList: %APPDATA%\Notepad++\functionList\

EXAMPLES
    .\install.ps1
    .\install.ps1 -NotepadPlusPlusPath "C:\Program Files\Notepad++"
    .\install.ps1 -Help

REQUIREMENTS
    - Notepad++ must be installed
    - AutoCompletion installation may require administrator privileges
    - PowerShell 5.0 or newer

"@
}

function Find-NotepadPlusPlus {
    $possiblePaths = @(
        "C:\Program Files (x86)\Notepad++",
        "C:\Program Files\Notepad++",
        "${env:ProgramFiles}\Notepad++",
        "${env:ProgramFiles(x86)}\Notepad++"
    )

    foreach ($path in $possiblePaths | Select-Object -Unique) {
        if (Test-Path -LiteralPath $path -PathType Container) {
            $notpadExe = Join-Path $path "notepad++.exe"
            if (Test-Path -LiteralPath $notpadExe -PathType Leaf) {
                return (Resolve-Path -LiteralPath $path).Path
            }
        }
    }

    return $null
}

function Test-IsAdmin {
    $currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Confirm-Installation {
    param(
        [string]$ComponentName,
        [string]$DestinationPath
    )

    Write-Host ""
    Write-Host "Install $ComponentName?" -ForegroundColor Yellow
    Write-Host "  Destination: $DestinationPath"
    Write-Host ""
    Write-Host "  [Y] Yes  [N] No (skip)" -ForegroundColor Cyan
    
    $response = Read-Host "Please enter Y or N"
    
    return ($response -eq "Y" -or $response -eq "y")
}

function Install-UDLFile {
    param(
        [string]$SourcePath,
        [string]$DestinationDir
    )

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
        Write-Host "✗ UDL file not found: $SourcePath" -ForegroundColor Red
        return $false
    }

    if (-not (Test-Path -LiteralPath $DestinationDir -PathType Container)) {
        Write-Host "  Creating directory: $DestinationDir"
        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
    }

    $fileName = Split-Path -Leaf $SourcePath
    $destFile = Join-Path $DestinationDir $fileName

    try {
        Copy-Item -LiteralPath $SourcePath -Destination $destFile -Force
        Write-Host "✓ Installed UDL file: $fileName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Failed to install UDL file" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Install-AutoCompletionFile {
    param(
        [string]$SourcePath,
        [string]$NotepadInstallDir
    )

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
        Write-Host "✗ AutoCompletion file not found: $SourcePath" -ForegroundColor Red
        return $false
    }

    $destDir = Join-Path $NotepadInstallDir "autoCompletion"
    $fileName = Split-Path -Leaf $SourcePath
    $destFile = Join-Path $destDir $fileName

    try {
        if (-not (Test-Path -LiteralPath $destDir -PathType Container)) {
            Write-Host "  Creating directory: $destDir"
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        Copy-Item -LiteralPath $SourcePath -Destination $destFile -Force
        Write-Host "✓ Installed AutoCompletion file: $fileName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Failed to install AutoCompletion file" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  This may require administrator privileges" -ForegroundColor Yellow
        return $false
    }
}

function Install-FunctionListFile {
    param(
        [string]$SourcePath,
        [string]$NotepadConfigDir
    )

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
        Write-Host "✗ FunctionList file not found: $SourcePath" -ForegroundColor Red
        return $false
    }

    $destDir = Join-Path $NotepadConfigDir "functionList"

    if (-not (Test-Path -LiteralPath $destDir -PathType Container)) {
        Write-Host "  Creating directory: $destDir"
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    $fileName = Split-Path -Leaf $SourcePath
    $destFile = Join-Path $destDir $fileName

    try {
        Copy-Item -LiteralPath $SourcePath -Destination $destFile -Force
        Write-Host "✓ Installed FunctionList file: $fileName" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Failed to install FunctionList file" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Update-OverrideMapXml {
    param(
        [string]$NotepadConfigDir,
        [string]$FunctionListFileName
    )

    $overrideMapPath = Join-Path $NotepadConfigDir "functionList\overrideMap.xml"

    if (-not (Test-Path -LiteralPath $overrideMapPath -PathType Leaf)) {
        Write-Host "✗ overrideMap.xml not found: $overrideMapPath" -ForegroundColor Red
        return $false
    }

    $writer = $null
    try {
        [xml]$xmlDoc = Get-Content -LiteralPath $overrideMapPath -Encoding UTF8
        
        # Find or create associationMap
        $associationMap = $xmlDoc.SelectSingleNode("//associationMap")
        if (-not $associationMap) {
            Write-Host "✗ Could not find associationMap in overrideMap.xml" -ForegroundColor Red
            return $false
        }

        # Check if Elvish association already exists
        $existingAssociation = $associationMap.SelectSingleNode("association[@name='Elvish']")
        if ($existingAssociation) {
            Write-Host "  Updating existing Elvish entry in overrideMap.xml" -ForegroundColor Yellow
            $existingAssociation.SetAttribute("functionList", $FunctionListFileName)
        }
        else {
            # Create new association element
            $newAssociation = $xmlDoc.CreateElement("association")
            $newAssociation.SetAttribute("name", "Elvish")
            $newAssociation.SetAttribute("functionList", $FunctionListFileName)
            $associationMap.AppendChild($newAssociation) | Out-Null
            Write-Host "  Added new Elvish entry to overrideMap.xml" -ForegroundColor Yellow
        }

        # Save with UTF8 encoding without BOM (matching Notepad++ convention)
        $settings = New-Object System.Xml.XmlWriterSettings
        $settings.Encoding = New-Object System.Text.UTF8Encoding($false)
        $settings.Indent = $true
        $settings.IndentChars = "    "

        $writer = [System.Xml.XmlWriter]::Create($overrideMapPath, $settings)
        $xmlDoc.WriteTo($writer)
        $writer.Flush()

        Write-Host "✓ Updated overrideMap.xml: Elvish association configured" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Failed to update overrideMap.xml" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        if ($writer) {
            $writer.Dispose()
        }
    }
}

# Main script execution
if ($Help) {
    Show-Help
    exit 0
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Elvish Notepad++ UDL Installer" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptDir) {
    $scriptDir = Get-Location
}

Write-Host "Script location: $scriptDir"
Write-Host ""

# Find or use provided Notepad++ path
$notepadPath = $null

if ($NotepadPlusPlusPath) {
    if (-not (Test-Path -LiteralPath $NotepadPlusPlusPath -PathType Container)) {
        Write-Host "✗ Notepad++ path not found: $NotepadPlusPlusPath" -ForegroundColor Red
        exit 1
    }

    $notepadExe = Join-Path $NotepadPlusPlusPath "notepad++.exe"
    if (-not (Test-Path -LiteralPath $notepadExe -PathType Leaf)) {
        Write-Host "✗ notepad++.exe not found in: $NotepadPlusPlusPath" -ForegroundColor Red
        exit 1
    }

    $notepadPath = (Resolve-Path -LiteralPath $NotepadPlusPlusPath).Path
}
else {
    Write-Host "Searching for Notepad++ installation..."
    $notepadPath = Find-NotepadPlusPlus
}

if (-not $notepadPath) {
    Write-Host "✗ Notepad++ installation not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please specify the Notepad++ installation path:" -ForegroundColor Yellow
    Write-Host "  .\install.ps1 -NotepadPlusPlusPath ""C:\Program Files\Notepad++""" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Found Notepad++ at: $notepadPath" -ForegroundColor Green
Write-Host ""

# Get Notepad++ config directory
$notepadConfigDir = Join-Path $env:APPDATA "Notepad++"

# Prepare source paths
$udlSource = Join-Path $scriptDir "UDLs\Elvish_byHoangLong.xml"
$acSource = Join-Path $scriptDir "autoCompletion\Elvish.xml"
$flSource = Join-Path $scriptDir "functionList\Elvish_byHoangLong.xml"

# Check if all required source files exist
$requiredFiles = @($udlSource, $acSource, $flSource)
$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        $missingFiles += (Split-Path -Leaf $file)
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "✗ Required source files not found!" -ForegroundColor Red
    Write-Host "  Missing files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "    - $file" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Found all required source files" -ForegroundColor Green
Write-Host ""

# Pre-check for AutoCompletion: if directory doesn't exist and we're not admin, warn early
$acDestDir = Join-Path $notepadPath "autoCompletion"
if (-not (Test-Path -LiteralPath $acDestDir -PathType Container)) {
    if (-not (Test-IsAdmin)) {
        Write-Host "⚠ Administrator privileges required" -ForegroundColor Yellow
        Write-Host "  (to create autoCompletion directory in: $acDestDir)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Please run this script as Administrator and try again." -ForegroundColor Yellow
        exit 1
    }
}

# Show summary
Write-Host "Installation Summary:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  UDL file:" -ForegroundColor Cyan
Write-Host "    Source: UDLs\Elvish_byHoangLong.xml" -ForegroundColor Gray
Write-Host "    Destination: $($notepadConfigDir)\userDefineLangs\" -ForegroundColor Gray
Write-Host ""
Write-Host "  AutoCompletion file:" -ForegroundColor Cyan
Write-Host "    Source: autoCompletion\Elvish.xml" -ForegroundColor Gray
Write-Host "    Destination: $($acDestDir)\" -ForegroundColor Gray
Write-Host ""
Write-Host "  FunctionList file:" -ForegroundColor Cyan
Write-Host "    Source: functionList\Elvish_byHoangLong.xml" -ForegroundColor Gray
Write-Host "    Destination: $($notepadConfigDir)\functionList\" -ForegroundColor Gray
Write-Host "    Also updates: $($notepadConfigDir)\functionList\overrideMap.xml" -ForegroundColor Gray
Write-Host ""

# Ask for confirmation for each component
$udlDest = Join-Path $notepadConfigDir "userDefineLangs"
$udlConfirm = Confirm-Installation -ComponentName "UDL file" -DestinationPath $udlDest

$acConfirm = Confirm-Installation -ComponentName "AutoCompletion file" -DestinationPath $acDestDir

$flDest = Join-Path $notepadConfigDir "functionList"
$flConfirm = Confirm-Installation -ComponentName "FunctionList file" -DestinationPath $flDest

Write-Host ""
Write-Host "Installing Elvish UDL support..."
Write-Host ""

# Track installation results
$installResults = @{
    "UDL" = "Pending"
    "AutoCompletion" = "Pending"
    "FunctionList" = "Pending"
}

# Install UDL file
if ($udlConfirm) {
    $udlSuccess = Install-UDLFile -SourcePath $udlSource -DestinationDir $udlDest
    
    if ($udlSuccess) {
        $installResults["UDL"] = "Installed"
    }
    else {
        $installResults["UDL"] = "Failed"
    }
}
else {
    $installResults["UDL"] = "Skipped"
}

# Install AutoCompletion file
if ($acConfirm) {
    $acSuccess = Install-AutoCompletionFile -SourcePath $acSource -NotepadInstallDir $notepadPath
    
    if ($acSuccess) {
        $installResults["AutoCompletion"] = "Installed"
    }
    else {
        $installResults["AutoCompletion"] = "Failed"
    }
}
else {
    $installResults["AutoCompletion"] = "Skipped"
}

# Install FunctionList file
if ($flConfirm) {
    $flSuccess = Install-FunctionListFile -SourcePath $flSource -NotepadConfigDir $notepadConfigDir
    
    if ($flSuccess) {
        # Update overrideMap.xml
        $flFileName = Split-Path -Leaf $flSource
        $mapSuccess = Update-OverrideMapXml -NotepadConfigDir $notepadConfigDir -FunctionListFileName $flFileName
        
        if ($mapSuccess) {
            $installResults["FunctionList"] = "Installed"
        }
        else {
            $installResults["FunctionList"] = "Failed"
        }
    }
    else {
        $installResults["FunctionList"] = "Failed"
    }
}
else {
    $installResults["FunctionList"] = "Skipped"
}

# Check for failures
$hasFailed = $installResults.Values | Where-Object { $_ -eq "Failed" }

# Display installation results
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Installation Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

foreach ($component in $installResults.Keys) {
    $status = $installResults[$component]
    
    if ($status -eq "Installed") {
        Write-Host "  ✓ $component`: Installed" -ForegroundColor Green
    }
    elseif ($status -eq "Skipped") {
        Write-Host "  - $component`: Skipped" -ForegroundColor Yellow
    }
    elseif ($status -eq "Failed") {
        Write-Host "  ✗ $component`: Failed" -ForegroundColor Red
    }
}

Write-Host ""

if ($hasFailed) {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host "  Installation Incomplete - Errors Detected" -ForegroundColor Red
    Write-Host "══��════════════════════════════════════════════════════════" -ForegroundColor Red
    Write-Host ""
    exit 1
}
else {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  Installation Complete" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    
    $installedCount = @($installResults.Values | Where-Object { $_ -eq "Installed" }).Count
    
    if ($installedCount -gt 0) {
        Write-Host "All requested components have been installed successfully." -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Close and restart Notepad++" -ForegroundColor Cyan
        Write-Host "2. Open an .elv file" -ForegroundColor Cyan
        Write-Host "3. Select Language > Elvish from the menu" -ForegroundColor Cyan
    }
    else {
        Write-Host "No components were installed (all were skipped)." -ForegroundColor Yellow
    }
    
    Write-Host ""
    exit 0
}
