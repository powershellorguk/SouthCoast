configuration DSC101 {
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    Registry EnableRDP {
        Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server';
        ValueName = 'fDenyTSConnections';
        ValueData = '0'
        ValueType = 'Dword';
        Ensure    = 'Present';
    }
}

## Compile the configuration into a mof
DSC101 -OutputPath ~\

## View the mof document
PSEdit ~\localhost.mof
