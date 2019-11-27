[CmdletBinding()]

param(
    [Parameter()]
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

    [Parameter()]
    [string[]]
    $AllowedMethods = ("Get", "Post"),

    [Parameter()]
    [string]
    $AllowedOrigin = "*",

    [Parameter()]
    [string]
    $AllowedHeaders = "*",

    [Parameter()]
    [Int32]
    $MaxAge = 180

)

try {
    Disable-AzContextAutosave -Scope Process | Out-Null
    $InformationPreference = "Continue"

    $creds = [System.Management.Automation.PSCredential]::New($ClientId,(ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force))
    Connect-AzAccount -ServicePrincipal -Tenant $TenantId -Subscription $SubscriptionId -Credential $creds | Out-Null
    Write-Information "Connected to Azure..."

    $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName

    foreach ($storageAccount in $storageAccounts) {
        Write-Information "Processing $($storageAccount.StorageAccountName)"...
        $context = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName

        $CorsRules = @{
            AllowedHeaders = $AllowedHeaders
            AllowedOrigins = $AllowedOrigin
            MaxAgeInSeconds = $MaxAge
            AllowedMethods= $AllowedMethods
            }

        if($CorsRules -eq (Get-AzStorageCORSRule -ServiceType Blob -Context $context)){
            Write-Information "CORS rule matches expected values...skipping..."
        }

        else {
            Write-Information -MessageData "Setting CORS rules on $($StorageAccountName)"
            Set-AzStorageCORSRule -ServiceType Blob -CorsRules $CorsRules -Context $Context
        }
    }
    Write-Information "Processed all storage accounts...done"
}
catch {
    Write-Output $error[0]
    exit 1
}
