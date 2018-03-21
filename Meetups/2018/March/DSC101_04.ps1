## Query the current LCM settings
Get-DscLocalConfigurationManager

configuration v4LCM {

    LocalConfigurationManager {
        RebootNodeIfNeeded = $true;
        DebugMode = 'ForceModuleImport';
        AllowModuleOverwrite = $true;
    }
}

## Compile the v4LCM configuration meta.mof
v4LCM -OutputPath ~\

[DSCLocalConfigurationManager()]
configuration v5LCM {
    param (
        [System.String[]] $ComputerName = 'localhost'
    )

    node $ComputerName {

        Settings {
            RebootNodeIfNeeded = $true;
            DebugMode = 'ForceModuleImport';
            AllowModuleOverwrite = $true;
        }
    
    } #end node
} #end configuration

## Compile the v5LCM configuration meta.mof
v5LCM -OutputPath ~\

## Push the meta.mof LCM confiuration
Set-DscLocalConfigurationManager -Path ~\ -Verbose

## Query the local LCM settings
Get-DscLocalConfigurationManager
