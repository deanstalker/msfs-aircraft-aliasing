$packageName = "Curtiss-P-40-Tomahawk"
$aliasPackageName = "mp-Curtiss-P-40-Tomahawk"

$airplaneName = "TOMAHAWK"
$aliasAirplaneName = "TOMAHAWK MP ONLY"

$icaoTypeDesignator = "P40"
$icaoModel = "P-40 Tomahawk" 
$icaoManufacturer = "BIGRADIAL" # payware manufacturer is incorrect, should be a common name of Curtiss

$scriptPath = "$PSScriptRoot"
$communityPath = (get-item $scriptPath).parent.parent.parent.parent.FullName

$packagePath = "$communityPath/$packageName"
$aliasPackagePath = "$communityPath/$aliasPackageName"

$aliasAirplanesPath = "$aliasPackagePath/SimObjects/Airplanes"

$airplanePath = "$aliasAirplanesPath/$airplaneName"
$aliasAirplanePath = "$aliasAirplanesPath/$aliasAirplaneName"

function AliasFsadniP40toBigRadial {
    ValidatePaths
    CleanupExistingAlias
    ClonePackage
    RenameAirplane

    UpdateManifest
    UpdateLayout
    UpdateTexturePaths

    UpdateAircraftConfig

    Pause
}

function ValidatePaths {
    if (-Not(Test-Path -Path "$packagePath")) {
        Write-Host "Please download and install 'Curtiss_P40_Tomahawk' from https://flightsim.to/file/27532/curtiss-p40-tomahawk"
        Pause
        ToMenu
    }
}

function CleanupExistingAlias {       
    if (Test-Path -Path "$aliasPackagePath") {
        Write-Host "It looks like we have created the alias already. Cleaning up alias ..."
        Remove-Item "$aliasPackagePath" -Recurse
    }
}

function ClonePackage {
    Write-Host "Cloning '$packagePath' to '$aliasPackagePath' ..."

    Copy-Item -Path "$packagePath" -Destination "$aliasPackagePath" -Recurse
}

function RenameAirplane {
    Write-Host "Rename '$airplaneName' to '$aliasAirplaneName'"

    Rename-Item -Path "$airplanePath" -NewName "$aliasAirplanePath"
    
}

function UpdateManifest {
    Write-Host "Update manifest.json ..."

    $json = Get-Content -Raw -Path "$aliasPackagePath/manifest.json" | ConvertFrom-Json
    $json.title = "P40_Tomahawk_(MP Only)"
    $output = ConvertTo-Json $json -Depth 10
    FixJsonIndentation $output | Set-Content "$aliasPackagePath/manifest.json"
}

function UpdateLayout {
    Write-Host "Update layout.json ..."

    $json = Get-Content -Raw -Path "$aliasPackagePath/layout.json" | ConvertFrom-Json

    Write-Host "Replacing '$airplanePath' paths"
    $content = @()
    foreach ($file in $json.content) {
        $path = $file.path            
        if ($path -like "*$airplaneName*") {
            Write-Host -NoNewline "#"        
            $path = $path.replace("$airplaneName", "$aliasAirplaneName")
            $file.path = $path
        }
        else {
            Write-Host -NoNewline "."
        }
        $content += $file
    }
    $json.content = $content
    $output = $json | ConvertTo-Json -Depth 10
    FixJsonIndentation $output | Set-Content "$aliasPackagePath/layout.json"
}

function UpdateTexturePaths {

    Write-Host "Updating texture paths"

    $textureConfigs = Get-ChildItem "$aliasAirplanePath" -Recurse texture.cfg -Depth 2 
    $textureConfigs | Select-Object Name, FullName
    $textureConfigs | Foreach-Object {
        Write-Host "... $($_.FullName)"
        $content = Get-IniFile $_.FullName
        $fallback = $content["fltsim"]["fallback.1"].replace($airplanePath, $aliasAirplanePath)
        $content["fltsim"]["fallback.1"] = $fallback
        $content | New-IniContent | Set-Content $_.FullName
    }    
}

function UpdateAircraftConfig {
    Write-Host "Update aircraft.cfg"

    $content = Get-IniFile "$aliasAirplanePath/aircraft.cfg"

    # Update General

    $general = $content["GENERAL"]
    $general.icao_type_designator = "`"$icaoTypeDesignator`""
    $general.icao_model = "`"$icaoModel`""
    $general.icao_manufacturer = "`"$icaoManufacturer`""
    $content["GENERAL"] = $general

    # Update Effects

    $content["EFFECTS"].Remove("Comment1")

    # Update Liveries

    foreach ($key in $content.keys) {
        if (-Not($key -like "FLTSIM.*")) {
            continue
        }
    
        $title = $content[$key].Title.Trim('"')
        $content[$key].Title = "`"$title (MP Only)`""
        $content[$key].ui_type = "`"P40 Tomahawk (MP Only)`""
        $content[$key].isUserSelectable = 0
    }

    $content | New-IniContent | Set-Content "$aliasAirplanePath/aircraft.cfg"
}