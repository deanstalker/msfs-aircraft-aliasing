$packageName = "Gloster Meteor F Mk8"

$airplaneName = "RobertRichardson_meteor_Aircraft"

$scriptPath = "$PSScriptRoot"
$communityPath = (get-item $scriptPath).parent.parent.parent.parent.FullName

$packagePath = "$communityPath/$packageName"
$airplanesPath = "$packagePath/SimObjects/Airplanes/"

$airplanePath = "$airplanesPath/$airplaneName"

function PatchGlosterMeteorMk8 {
    ValidatePaths
    PatchAircraft
}

function ValidatePaths {
    if (-Not(Test-Path -Path "$packagePath")) {
        Write-Host "You can download and install Rob Richardson's Gloster Meteor F Mk.8 from the Sim-outhouse.com Warbirds Library (http://www.sim-outhouse.com/sohforums/local_links.php?catid=247) - Account Registration Required"
        pause
        break
    }    
}

function PatchAircraft {
    Write-Host "Patching aircraft.cfg ..."

    $aircraftCfg = "$airplanePath/aircraft.cfg"

    Copy-Item "$aircraftCfg" "$aircraftCfg.bak"

    $content = Get-IniFile "$aircraftCfg"

    if ($content["GENERAL"]["icao_type_designator"] -eq "`"METR`"") {
        Write-Host "Patch already applied, skipping"
        pause
        break
    }

    $content["EXITS"].Remove("Comment1")

    $content["GENERAL"]["icao_type_designator"] = "`"METR`""

    $content | New-IniContent | Set-Content "$aircraftCfg"    
}
