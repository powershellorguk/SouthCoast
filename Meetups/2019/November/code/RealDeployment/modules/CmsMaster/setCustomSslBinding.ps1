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
    $WebAppName,

    [Parameter(Mandatory)]
    [string]
    $WebAppCustomDomain,

    [Parameter(Mandatory)]
    [string]
    $WebAppSlotCustomDomain,

    [Parameter(Mandatory)]
    [string]
    $SslCertificate,

    [Parameter(Mandatory)]
    [string]
    $SslPassword
)

try {
    Import-Module Az.Accounts, Az.Websites, Az.Resources
    Disable-AzContextAutosave -Scope Process

    $cred = [System.Management.Automation.PSCredential]::new($ClientId,(ConvertTo-SecureString $clientSecret -AsPlainText -Force))
    Connect-AzAccount -Credential $cred -ServicePrincipal -Tenant $TenantId -Subscription $SubscriptionId

    $webApp = Get-AzWebApp -ResourceGroupName $ResourceGroup -Name $WebAppName
    $slot = Get-AzWebAppSlot -ResourceGroupName $ResourceGroup -Name $WebAppName

    if (!($webApp.hostnames.IndexOf($WebAppCustomDomain) -ge 0)) {
        $hostnames = $webApp.hostnames + $WebAppCustomDomain
        Set-AzWebApp -ResourceGroupName $ResourceGroup -Name $WebAppName -HostNames $hostnames

        $params = @{
            ResourceGroupName   = $ResourceGroup
            WebAppName          = $WebAppName
            Name                = $WebAppCustomDomain
            CertificateFilePath = $SslCertificate
            CertificatePassword = $SslPassword
            SslState            = "IpBasedEnabled"
        }
        New-AzWebAppSSLBinding @params
    }

    if (!($slot.hostnames.IndexOf($WebAppSlotCustomDomain) -ge 0)) {
        $params = @{
            Location            = $slot.Location
            ResourceGroupName   = $ResourceGroup
            ResourceType        = "Microsoft.Web/sites/slots/hostNameBindings"
            ResourceName        = "$($slot.Name)/$WebAppSlotCustomDomain"
            ApiVersion          = "2018-02-01"
            Force               = $true
        }
        New-AzResource @params

        $params = @{
            ResourceGroupName   = $ResourceGroup
            WebAppName          = $WebAppName
            Slot                = $slot.Name.Split("/")[1]
            Name                = $WebAppSlotCustomDomain
            CertificateFilePath = $SslCertificate
            CertificatePassword = $SslPassword
            SslState            = "IpBasedEnabled"
        }
        New-AzWebAppSSLBinding @params
    }
}
catch {
    Write-Error $error[0]
    exit 1
}
