[CmdletBinding()]

param
(
    [Parameter(Mandatory)]
    [string]
    $Uri,

    [Parameter(Mandatory)]
    [string]
    $Username,

    [Parameter(Mandatory)]
    [string]
    $Password,

    [Parameter()]
    [string]
    $ParameterSet
)

try {

    $AsciiBytes = [Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)")
    $credentials = [Convert]::ToBase64String($AsciiBytes)

    $headers = @{
        Authorization = ("Basic {0}" -f $credentials)
    }

    $params = @{
        Uri         = $Uri
        Headers     = $headers
        Method      = "Post"
        ContentType = "application/json"
    }

    if ($ParameterSet) {
        $params.Uri = "$Uri`?arguments=$ParameterSet"
    }

    Invoke-RestMethod @params

} catch {
    $scriptError = $_ -split '\n'
    if ($scriptError.count -gt 1) {
        foreach ($item in $scriptError) {
            Write-Error $item
        }
    } else {
        Write-Error $scriptError
    }
    exit 1
}
