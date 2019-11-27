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
    $ResourceGroup
)

$InformationPreference = "Continue"
Disable-AzContextAutosave -Scope Process | Out-Null
Import-Module Az.Accounts, Az.Resources, Az.Network

$creds = [System.Management.Automation.PSCredential]::new($ClientId, (ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -Credential $creds -ServicePrincipal | Out-Null

$rulesToDisables = @(
    [PSCustomObject]@{ruleGroupName = "REQUEST-931-APPLICATION-ATTACK-RFI"; rules = @("931130");},
    [PSCustomObject]@{ruleGroupName = "REQUEST-942-APPLICATION-ATTACK-SQLI"; rules = @("942260","942330","942340","942370");}
)

$appGateways = Get-AzApplicationGateway -ResourceGroupName $ResourceGroup

foreach ($appGw in $appGateways) {
    $resource = Get-AzResource -Name $appGw.Name -ResourceType "Microsoft.Network/applicationGateways" -ResourceGroupName $ResourceGroup -ApiVersion "2018-07-01"
    $resource.Properties.webApplicationFirewallConfiguration.disabledRuleGroups = $rulesToDisables
    $resource | Set-AzResource -Force -ApiVersion "2018-07-01"
}
