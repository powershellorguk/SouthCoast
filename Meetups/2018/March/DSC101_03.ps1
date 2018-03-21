configuration DSC101 {
    param (
        [System.String[]] $ComputerName = 'localhost'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    node $ComputerName {
    
        Registry 'EnableRDP' {
            Key       = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server';
            ValueName = 'fDenyTSConnections';
            ValueData = '0'
            ValueType = 'Dword';
            Ensure    = 'Present';
        }
    
    } #end node
} #end configuration

DSC101 -OutputPath ~\ -ComputerName A,B,C,D,E
