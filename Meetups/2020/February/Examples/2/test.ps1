Connect-AzAccount
$context = (Get-AzStorageAccount -ResourceGroupName "RG-TerraformTest" -Name "faef0c50024249088649ef85").Context
Get-AzStorageBlob -Container "demo-container" -Context $context
