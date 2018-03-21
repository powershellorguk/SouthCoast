## Review the DSC commands
Get-Command -Module PSDesiredStateConfiguration

## Push the compiled mof (to localhost)
Start-DscConfiguration -Path ~\ -Verbose -Wait

## Retrieve the current configuration
Get-DscConfiguration

## Test the configuration has applied successfully
Test-DscConfiguration -Verbose

## Retrieve the last configuration status (v5 only)
Get-DscConfigurationStatus

## Current and previous mofs are stored in
## C:\Windows\System32\Configuration. They are
## automatically encrypted with v5, but not with v4
PSEdit 'C:\Windows\System32\Configuration\Current.mof'

## Remove the current configuration
Remove-DscConfigurationDocument -Stage Current -Verbose

## Will error as there is no configuration!
Get-DscConfiguration
