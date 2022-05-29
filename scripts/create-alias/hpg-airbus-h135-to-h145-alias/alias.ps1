$packageName = "hpg-airbus-h135"
$paywarePackageName = "hpg-airbus-h145"
$aliasPackageName = "mp-hpg-airbus-h145"

$airplaneName = "H-135 DEV SERIES PROJECT"
$aliasAirplaneName = "H-145 MP ONLY"
$removeAirplaneName = "H-135 DEV HIGH SKIDS"

$scriptRoot = "$PSScriptRoot"
$communityPath = (get-item $scriptRoot).parent.parent.parent.parent.FullName

$paywarePackagePath = "$communityPath/$paywarePackageName"
$packagePath = "$communityPath/$packageName"
$aliasPackagePath = "$communityPath/$aliasPackageName"

$aliasAirplanesPath = "$aliasPackagePath/SimObjects/Airplanes/"

$airplanePath = "$aliasAirplanesPath/$airplaneName"
$aliasAirplanePath = "$aliasAirplanesPath/$aliasAirplaneName"
$removeAirplanePath = "$aliasAirplanesPath/$removeAirplaneName"

function AliasH135toH145 {    
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
    Write-Host "$paywarePackagePath"
    if (Test-Path -Path "$paywarePackagePath") {
        Write-Host "It looks like you own the payware HPG Airbus H145. You shouldn't need to alias this aircraft."    
        Pause
        ToMenu
    }
    
    if (-Not(Test-Path -Path "$packagePath")) {
        Write-Host "Please download and install 'HPG H135 Helicopter Project' from https://flightsim.to/file/8970/airbus-h135-helicopter-project"
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
    Write-Host "Cloning '$packageName' to '$aliasPackageName' ..."

    Copy-Item -Path "$packagePath" -Destination "$aliasPackagePath" -Recurse        
}

function RemoveHighSkids {
    if (Test-Path -Path "$removeAirplanePath") {
        Write-Host "Removing the $removeAirplaneName folder to simplify the alias ..."
        Remove-Item -Path "removeAirplanePath" -Recurse
    }      
}

function RenameAirplane {
    Write-Host "Rename '$airplaneName' to '$aliasAirplaneName'"

    Rename-Item -Path "$airplanePath" -NewName "$aliasAirplanePath"
}

function UpdateManifest {
    Write-Host "Update manifest.json ..."

    $json = Get-Content -Raw -Path "$aliasPackagePath/manifest.json" | ConvertFrom-Json
    $json.title = "H145"
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

        if (-Not($path -like "*$removeAirplanePath*")) {
            $content += $file
        }
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
    $general.icao_type_designator = "`"H145`""
    $general.icao_model = "`"H-145`""
    $content["GENERAL"] = $general
    
    # Update Effects
    
    $content["EFFECTS"].Remove("Comment1")
    
    # Update Liveries
    
    foreach ($key in $content.keys) {
        if (-Not($key -like "FLTSIM.*")) {
            continue
        }
    
        $title = $content[$key].Title.Trim('"')
        $content[$key].Title = "`"$title (H-145 Alias)`""
        $content[$key].ui_type = "`"H145 (MP Alias)`""
        $content[$key].isUserSelectable = 0
    }
    
    $content | New-IniContent | Set-Content "$aliasAirplanePath/aircraft.cfg"   
}