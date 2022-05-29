$ErrorActionPreference = 'Stop'

$scriptRoot = "$PSScriptRoot"
$scriptsPath = "$scriptRoot/scripts"
$utilsPath = "$scriptsPath/utils"
$communityPath = (get-item $scriptRoot).FullName

. "$utilsPath/ini.ps1"
. "$utilsPath/json.ps1"

. "$scriptsPath/menu/menu.ps1"

do {
  Show-Menu
  $selection = Read-Host "Please make a selection"
  switch ($selection) {
      "1" {
        . "$scriptsPath/create-alias/hpg-airbus-h135-to-h145-alias/alias.ps1"
        aliasH135toH145
      }
      "2" {
        . "$scriptsPath/create-alias/fsadni-p40-to-bigradials-p40-alias/alias.ps1"
        AliasFsadniP40toBigRadial
      }
      "3" {        
        . "$scriptsPath/patch/rob-richardson-gloster-meteor-icao-fix/patch.ps1"
        patchGlosterMeteorMk8
      }
      Default {}
  }
} until (
  $selection -eq 'q'
)