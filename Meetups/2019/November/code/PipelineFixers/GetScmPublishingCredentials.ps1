[CmdletBinding()]

param (
    [Parameter(Mandatory)]
    [string]
    $SubscriptionId,

    [Parameter(Mandatory)]
    [string]
    $TenantId,

    [Parameter(Mandatory)]
    [string]
    $ClientId,

    [Parameter(Mandatory)]
    [string]
    $ClientSecret,

    [Parameter(Mandatory)]
    [alias("Name")]
    [string[]]
    $WebAppName,

    [Parameter(Mandatory)]
    [string]
    $ResourceGroup,

    [Parameter(Mandatory)]
    [string]
    [alias("SlotName")]
    $WebAppSlot
)

function Write-Info {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object[]]
        $Message
    )

    process {
        foreach ($item in $Message) {
            if ($item.GetType().Name -eq "String") {
                Write-Information -MessageData $item -InformationAction Continue
            } elseif ($item.GetType().Name -match "[]") {
                Write-Info -Message $item
            } else {
                Write-Information -MessageData $item.ToSting() -InformationAction Continue
            }
        }
    }
}

try {

    Write-Info -Message "Importing Modules..."
    Import-Module AzureRm.Profile, AzureRm.Resources

    Write-Info -Message "Setting API Version and writing debug statements..."
    $ApiVersion = "2018-11-01"
    Write-Info -Message "Api Version: $ApiVersion"
    Write-Info -Message "WebApps: $($WebAppName.count)"

    Write-Info -Message "Connecting to Azure..."
    Disable-AzureRmContextAutosave -Scope Process
    $credential = [System.Management.Automation.PSCredential]::new($ClientId, (ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force))
    Connect-AzureRmAccount -Subscription $SubscriptionId -Tenant $TenantId -Credential $credential -ServicePrincipal | Out-Null

    # Get SCM Credentials
    Write-Info -Message "Creating results array..."
    $webAppScmCredentials = @()
    Write-Info -Message "Entering foreach loop..."
    foreach ($webApp in $WebAppName) {
        Write-Info -Message "Loop for $webApp..."
        # First do the base WebApps
        Write-Info -Message "Creating parameter object..."
        $params = @{
            ResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Web/sites/$webApp/config/publishingcredentials"
            Action     = "list"
            ApiVersion = $ApiVersion
            Force      = $true
        }
        Write-Info -Message "Retrieving data from Azure..."
        $res = Invoke-AzureRmResourceAction @params
        Write-Info -Message "Username Type: $($res.properties.publishingUsername.GetType())"
        $username = $res.properties.publishingUsername
        $password = $res.properties.publishingPassword
        $uri = $res.properties.scmUri.replace("$($res.properties.publishingUsername):$($res.properties.publishingPassword)@", "")
        $appCreds = @{
            Name     = $webApp
            Slot     = $false
            Username = $username
            Password = $password
            Uri      = $uri
        }
        Write-Info -Message "WebApp: $webApp"
        Write-Info -Message "Username: $username"
        Write-Info -Message "Uri: $uri"
        $webAppScmCredentials += $appCreds

        # Now do the slots
        $Params.ResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Web/sites/$webApp/slots/$WebAppSlot/config/publishingcredentials"
        $res = Invoke-AzureRmResourceAction @params
        $username = $res.properties.publishingUsername
        $password = $res.properties.publishingPassword
        $uri = $res.properties.scmUri.replace("$($res.properties.publishingUsername):$($res.properties.publishingPassword)@", "")
        $slotCreds = @{
            Name     = $webApp
            Slot     = $true
            Username = $username
            Password = $password
            Uri      = $uri
        }
        Write-Info -Message "WebApp: $webApp"
        Write-Info -Message "Username: $username"
        Write-Info -Message "Uri: $uri"
        $webAppScmCredentials += $slotCreds
    }

    Write-Info -Message "SCM Credential Count: $($webAppScmCredentials.count)"

    foreach ($site in $webAppScmCredentials) {
        $outputId = $site.Name.split("-")[-1]

        if ($site.Slot) {
            Write-Host "##vso[task.setvariable variable=ScmSlotUri$($outputId);]$($site.Uri)/api/triggeredwebjobs/"
            Write-Host "##vso[task.setvariable variable=ScmSlotUsername$($outputId);]$($site.Username)"
            Write-Host "##vso[task.setvariable variable=ScmSlotPassword$($outputId); issecret=true;]$($site.Password)"
        } else {
            Write-Host "##vso[task.setvariable variable=ScmUri$($outputId);]$($site.Uri)/api/triggeredwebjobs/"
            Write-Host "##vso[task.setvariable variable=ScmUsername$($outputId);]$($site.Username)"
            Write-Host "##vso[task.setvariable variable=ScmPassword$($outputId); issecret=true;]$($site.Password)"
        }
    }
} catch {
    $scriptError = $_ -split "/n"
    if ($scriptError.count) {
        $scriptError | ForEach-Object {Write-Error $_}
    } else {
        Write-Error $scriptError
    }
    exit 1
}
