[CmdletBinding()]

param(
    [Parameter(Mandatory)]
    [string]
    $ResourceGroupName,

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
    [string]
    $SslPolicy
)

try {
    $InformationPreference = "Continue"
    Disable-AzContextAutosave -Scope Process | Out-Null

    Write-Information "Connecting to Azure.."
    $creds = [System.Management.Automation.PSCredential]::New($ClientId,(ConvertTo-SecureString $ClientSecret -AsPlainText -Force))
    Connect-AzAccount -ServicePrincipal -Tenant $TenantId -Subscription $SubscriptionId -Credential $creds | Out-Null

    $appGateways = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName

    foreach ($appGateway in $appGateways) {
        Write-Information "Processing $($appGateway.Name)..."
        $checkParams = @{
            ResourceGroupName   = $ResourceGroupName
            ResourceType        = "Microsoft.Network/applicationGateways"
            ResourceName        = $appGateway.Name
            ApiVersion          = "2018-07-01"
        }
        $appGatewayDetails = Get-AzResource @checkParams
        Write-Information "Retrieved details..."

        if ($appGatewayDetails.Properties.sslPolicy.policyName) {
            if ($appGatewayDetails.Properties.sslPolicy.policyName -ne $SslPolicy) {
                Write-Information "Policy not expected value...resetting..."
                $appGatewayDetails.Properties.sslPolicy.policyName = $SslPolicy
                $appGatewayDetails.Properties.sslPolicy.policyType = "Predefined"

                $setParams = @{
                    ResourceGroupName   = $ResourceGroupName
                    ResourceType        = $checkParams.ResourceType
                    ResourceName        = $appGateway.Name
                    PropertyObject      = $appGatewayDetails.Properties
                    ApiVersion          = $checkParams.ApiVersion
                    Force               = $true
                }
                Set-AzResource @setParams | Out-Null
            } else {
                Write-Information "Policy already set to expected value...skipping..."
            }
        } else {
            Write-Information "Policy not expected value...resetting..."
            $appGatewayDetails.Properties.sslPolicy | Add-Member -NotePropertyMembers ([ordered]@{policyName = $SslPolicy; policyType = "Predefined"})
        }
        Write-Information "Finished processing $($appGateway.Name)..."
    }
    Write-Information "All AppGateways checked... done"
}
catch {
    Write-Output $Error[0]
    exit 1
}
