Function Set-Timezone {
    <#
      .Synopsis
      A function that sets the computer timezone.

      .Description
      This function is a wrapper around tzutil.exe, aiming to make setting timezones slightly easier.

      .Parameter Timezone
      A string containing the display name of the timezone you require.
      Only valid timezones (from 'Get-Timezone -All', or 'tzutil /l') are supported.

      .Parameter WhatIf
      If Whatif is specified, the user is notified about the timezone that would be set.

      .Parameter Confirm
      If Confirm is specified, the command will ask for input to change the currently effective timezone.

      .Example
      Set-Timezone -Timezone 'Singapore Standard Time'

      Set the timezone to Singapore standard time (UTC+08:00).

      .Notes
      Author: David Green (http://tookitaway.co.uk/)
    #>

    [CmdletBinding(
        SupportsShouldProcess = $True,
        ConfirmImpact         = 'Medium'
    )]

    Param(
        [Parameter(
            Position                        = 1,
            Mandatory                       = $True,
            ValueFromPipeline               = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage                     = 'Specify the timezone to set (from "Get-Timezone -All").'
        )]
        [ValidateScript({
            if (Get-Timezone -Timezone $_) {
                $True
            }
        })]
        [string]$Timezone
    )

    if ($PSCmdlet.ShouldProcess($Timezone)) {
        Write-Verbose "Setting Timezone to $Timezone"
        tzutil.exe /s $Timezone
    }
}