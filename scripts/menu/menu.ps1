function Show-Menu {
    param (
        [string]$Title = 'Aircraft Aliasing'
    )
    
    Clear-Host
    Write-Host "$([char]0x2708)$([char]0x2708)$([char]0x2708)$([char]0x2708)$([char]0x2708)$([char]0x2708) $Title $([char]0x2708)$([char]0x2708)$([char]0x2708)$([char]0x2708)$([char]0x2708)"
    
    Write-Host ""

    Write-Host "Create Multiplayer Alias"

    Write-Host "    1: Create HPG Airbus 145 alias from HPG Airbus 135 (clone)"    
    Write-Host "    2: Create BIGRADIALS P40 Tomahawk alias from FSAdni's P40 Tomahawk (clone)"

    Write-Host ""

    Write-Host "Patch Aircraft"

    Write-Host "    3: Patch Rob Richardson's Gloster Meteor MK.8 ICAO settings (patch only)" 
}