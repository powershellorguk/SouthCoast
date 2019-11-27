[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $TenantId,

    [Parameter(Mandatory)]
    [string]
    $SubscriptionId,

    [Parameter(Mandatory)]
    [string]
    $ClientId,

    [Parameter(Mandatory)]
    [string]
    $ClientSecret,

    [Parameter(Mandatory)]
    [string]
    $ResourceGroup,

    [Parameter(Mandatory)]
    [string]
    $WebApp,

    [Parameter(Mandatory)]
    [string]
    $SlotName,

    [Parameter(Mandatory)]
    [string]
    $SettingName,

    [Parameter(Mandatory)]
    [string]
    $SettingValue,

    [Parameter(Mandatory)]
    [string]
    $AppInsightsKey,

    [Parameter()]
    [switch]
    $UpdateSlot
)

function Write-Info {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $Message
    )

    process {
        foreach ($line in $Message) {
            if ($line.count -gt 1) {
                Write-Info -Message $line
            } else {
                Write-Information -MessageData $line -InformationAction Continue
            }
        }
    }
}

function Connect-Azure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $TenantId,

        [Parameter(Mandatory)]
        [string]
        $SubscriptionId,

        [Parameter(Mandatory)]
        [string]
        $ClientId,

        [Parameter(Mandatory)]
        [string]
        $ClientSecret
    )

    process {
        $secret = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
        $cred = [System.Management.Automation.PSCredential]::new($ClientId, $secret)
        $accountParams = @{
            ServicePrincipal = $true
            Tenant           = $TenantId
            Subscription     = $SubscriptionId
            Credential       = $cred
            WarningAction    = "SilentlyContinue"
        }
        Connect-AzAccount @accountParams | Out-Null
    }
}

function Get-AppSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ResourceGroup,

        [Parameter(Mandatory)]
        [string]
        $WebApp,

        [Parameter()]
        [string]
        $SlotName,

        [Parameter()]
        [switch]
        $DeploymentSettings
    )

    process {
        if ($DeploymentSettings) {
            $settings = Get-AzWebAppSlotConfigName -ResourceGroupName $ResourceGroup -Name $WebApp
            $result = $settings.AppSettingNames
        } else {
            if ($SlotName) {
                $settings = Get-AzWebAppSlot -ResourceGroupName $ResourceGroup -Name $WebApp -Slot $SlotName
            } else {
                $settings = Get-AzWebApp -ResourceGroupName $ResourceGroup -Name $WebApp
            }
            $result = $settings.SiteConfig.AppSettings
        }
        Write-Output $result
    }
}

function Remove-SlotSetting {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory)]
        [string]
        $ResourceGroup,

        [Parameter(Mandatory)]
        [string]
        $WebApp,

        [Parameter(Mandatory)]
        [string]
        $Setting
    )

    process {
        $deploymentSettings = Get-AppSettings -ResourceGroup $ResourceGroup -WebApp $WebApp -DeploymentSettings

        if ($deploymentSettings.count -eq 1) {
            Set-AzWebAppSlotConfigName -ResourceGroupName $ResourceGroup -Name $WebApp -RemoveAllAppSettingNames | Out-Null
        } else {
            $deploymentSettings = $deploymentSettings | Where-Object {$_.Name -ne "$Setting"}
            Set-AzWebAppSlotConfigName -ResourceGroupName $ResourceGroup -Name $WebApp -AppSettingNames $deploymentSettings | Out-Null
        }
    }
}

function Add-AppSetting {
    [CmdletBinding()]

    param(
        [Parameter(Mandatory)]
        [string]
        $ResourceGroup,

        [Parameter(Mandatory)]
        [string]
        $WebApp,

        [Parameter()]
        [string]
        $SlotName,

        [Parameter(Mandatory)]
        [string]
        $Setting,

        [Parameter(Mandatory)]
        [string]
        $Value
    )

    process {
        if ($SlotName) {
            $appSettings = Get-AppSettings -ResourceGroup $ResourceGroup -WebApp $WebApp -SlotName $SlotName
            $settings = @{ }
            foreach ($appSetting in $appSettings) {
                $settings[$appSetting.Name] = $appSetting.Value
            }
            $settings[$Setting] = $Value
            Set-AzWebAppSlot -ResourceGroupName $ResourceGroup -Name $WebApp -Slot $SlotName -AppSettings $settings | Out-Null
        } else {
            $appSettings = Get-AppSettings -ResourceGroup $ResourceGroup -WebApp $WebApp
            $settings = @{ }
            foreach ($appSetting in $appSettings) {
                $settings[$appSetting.Name] = $appSetting.Value
            }
            $settings[$Setting] = $Value
            Set-AzWebApp -ResourceGroupName $ResourceGroup -Name $WebApp -AppSettings $settings | Out-Null
        }
    }
}

try {
    Write-Info -Message "Importing Module..."
    Import-Module Az.Websites, Az.Accounts
    Disable-AzContextAutosave -Scope Process

    $aiSetting = "APPINSIGHTS_INSTRUMENTATIONKEY";

    Write-Info -Message "Connecting to Azure..."
    Connect-Azure -TenantId $TenantId -SubscriptionId $SubscriptionId -ClientId $ClientId -ClientSecret $ClientSecret
    Write-Info -Message "Connected!"

    Write-Info -Message "Retrieving SlotConfig settings..."
    $stickySettings = Get-AppSettings -ResourceGroup $ResourceGroup -WebApp $WebApp -DeploymentSettings
    if ($null -eq $stickySettings) {
        $tagFound = $false
        Write-Info -Message "No 'sticky' settings found!"
    } elseif ($stickySettings.Contains($SettingName)) {
        $tagFound = $true
        Write-Info -Message "$SettingName found in list of 'sticky' items..."
    } else {
        $tagFound = $false
        Write-Info -Message "$SettingName not in list of 'sticky' items..."
    }

    Write-Info -Message "Collecting settings from WebApp & Slot..."
    $webAppSettings = Get-AppSettings -ResourceGroup $ResourceGroup -WebApp $WebApp
    $slotSettings = Get-AppSettings -ResourceGroup $ResourceGroup -WebApp $WebApp -SlotName $SlotName
    $webAppValue = $webAppSettings.Where( { $_.Name -eq $SettingName }).Value
    $slotValue = $slotSettings.Where( { $_.Name -eq $SettingName }).Value
    $webAppInsightsKey = $webAppSettings.Where( { $_.Name -eq $aiSetting }).Value
    $slotAppInsightsKey = $slotSettings.Where( { $_.Name -eq $aiSetting }).Value
    Write-Info -Message "Done!"

    Write-Info -Message "Checking if '$SettingName' is configured as deployment setting..."
    if ($tagFound) {
        Write-Info -Message "...Found '$SettingName' as deployment setting... Removing..."
        Remove-SlotSetting -ResourceGroup $ResourceGroup -WebApp $WebApp -Setting $SettingName
    }

    if ($UpdateSlot) {
        Write-Info -Message "Will update WebApp in Slot if required...Checking slot settings..."
        if ($slotValue -eq $SettingValue) {
            Write-Info -Message "Slot has desired setting value...Checking WebApp settings..."
            if ($webAppValue -ne $SettingValue) {
                Write-Info -Message "WebApp doesn't have duplicate value...No change required!"
            } else {
                Write-Info -Message "WebApp has duplicate value... Manual intervention required!"
                Write-Error -Message "WebApp and Slot have duplicate values for '$SettingName'!"
            }
        } else {
            Write-Info -Message "Slot has different setting value...Checking WebApp settings..."
            if ($webAppValue -eq $SettingValue) {
                Write-Info -Message "WebApp has desired setting value...No change required!"
            } else {
                Write-Info -Message "WebApp has different setting value...Updating slot to match desired value..."
                Add-AppSetting -ResourceGroup $ResourceGroup -WebApp $WebApp -SlotName $SlotName -Setting $SettingName -Value $SettingValue
            }
        }
    } else {
        Write-Info -Message "Will update WebApp if required...Checking WebApp settings..."
        if ($webAppValue -eq $SettingValue) {
            Write-Info -Message "WebApp has desired setting value...Checking slot settings..."
            if ($slotValue -ne $SettingValue) {
                Write-Info -Message "Slot doesn't have duplicate value...No change required!"
            } else {
                Write-Info -Message "Slot has duplicate value... Manual intervention required!"
                Write-Error -Message "WebApp and Slot have duplicate values for '$SettingName'!"
            }
        } else {
            Write-Info -Message "WebApp has different setting value...Checking slot settings..."
            if ($slotValue -eq $SettingValue) {
                Write-Info -Message "Slot has desired setting value...No change required!"
            } else {
                Write-Info -Message "Slot has different setting value...Updating WebApp to match desired value..."
                Add-AppSetting -ResourceGroup $ResourceGroup -WebApp $WebApp -Setting $SettingName -Value $SettingValue
            }
        }
    }

    Write-Info -Message "Checking for AppInsights Keys..."
    if ($webAppInsightsKey -eq $AppInsightsKey) {
        Write-Info -Message "WebApp has correct value..."
    } else {
        Write-Info -Message "WebApp has incorrect value...Updating..."
        Add-AppSetting -ResourceGroup $ResourceGroup -WebApp $WebApp -Setting $aiSetting -Value $AppInsightsKey
    }
    if ($slotAppInsightsKey -eq $AppInsightsKey) {
        Write-Info -Message "Slot has correct value..."
    } else {
        Write-Info -Message "Slot has incorrect value...Updating..."
        Add-AppSetting -ResourceGroup $ResourceGroup -WebApp $WebApp -SlotName $SlotName -Setting $aiSetting -Value $AppInsightsKey
    }

    Write-Info -Message "Applying AppSettings to auto-enable AppInsights..."
    $aiSettings = @(
        @{APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"},
        @{APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"},
        @{ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"},
        @{DiagnosticServices_EXTENSION_VERSION            = "~3"},
        @{InstrumentationEngine_EXTENSION_VERSION         = "disabled"},
        @{SnapshotDebugger_EXTENSION_VERSION              = "disabled"},
        @{XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"},
        @{XDT_MicrosoftApplicationInsights_Mode           = "recommended"}
    )
    for ($i = 0; $i -lt $aiSettings.Count; $i++) {
        Add-AppSetting -ResourceGroup $ResourceGroup -WebApp $WebApp -Setting $aiSettings[$i].Keys -Value $aiSettings[$i].Values
        Add-AppSetting -ResourceGroup $ResourceGroup -WebApp $WebApp -SlotName $SlotName -Setting $aiSettings[$i].Keys -Value $aiSettings[$i].Values
    }
    Write-Info -Message "Applied AppSettings to auto-enable AppInsights..."

    Disconnect-AzAccount | Out-Null
} catch {
    Write-Info -Message "Errors encountered: $($Error.Count)..."
    Write-Info -Message "Last error:"
    $scriptError = $Error[0]
    Write-Error $scriptError
    exit 1
}
