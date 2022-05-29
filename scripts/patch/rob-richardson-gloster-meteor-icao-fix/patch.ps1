$packageName = "Gloster Meteor F Mk8"
$airplaneName = "RobertRichardson_meteor_Aircraft"

$scriptPath = "$PSScriptRoot"

$parentPath = (get-item $scriptPath).parent.parent.FullName
$communityPath = (get-item $scriptPath).parent.parent.parent.FullName
$utilsPath = "$((get-item $scriptPath).parent.FullName)/utils"

. "$utilsPath/ini.ps1"
. "$utilsPath/json.ps1"
. "$utilsPath/menu.ps1"

$packagePath = "$communityPath/$packageName"
$airplanePath = "$packagePath/SimObjects/Airplanes/$airplaneName"

if (-Not(Test-Path -Path "$packagePath")) {
    Write-Host "You can download and install Rob Richardson's Gloster Meteor F Mk.8 from the Sim-outhouse.com Warbirds Library (http://www.sim-outhouse.com/sohforums/local_links.php?catid=247) - Account Registration Required"
    Pause
    ToMenu
}

Write-Host "Patching aircraft.cfg ..."

$aircraftCfg = "$airplanePath/aircraft.cfg"

Copy-Item "$aircraftCfg" "$aircraftCfg.bak"

$content = Get-IniFile "$aircraftCfg"

if ($content["GENERAL"]["icao_type_designator"] -eq "`"METR`"") {
    Write-Host "Patch already applied, skipping"
    Pause
    ToMenu
}

$content["EXITS"].Remove("Comment1")

$content["GENERAL"]["icao_type_designator"] = "`"METR`""

$content | New-IniContent | Set-Content "$aircraftCfg"

Write-Host "Done"

Pause
ToMenu 

