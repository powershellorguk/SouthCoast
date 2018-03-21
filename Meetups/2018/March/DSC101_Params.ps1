Configuration Params {
    param (
        [Parameter(Mandatory)]
        [Switch] $DisableServerManager,

        [Parameter()]
        [Boolean] $ICMP
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    Import-DscResource -ModuleName xNetworking;
    Import-DscResource -modulename xWinEventLog;
    Import-DscResource -modulename PolicyFileEditor;

    Registry 'DoNotOpenServerManagerAtLogon' {
        Key = 'HKLM:\Software\Microsoft\ServerManager';
        ValueName = 'DoNotOpenServerManagerAtLogon';
        ValueData = $DisableServerManager.ToBool() -as [System.Int32];
        ValueType = 'Dword';
    }
    
    xFirewall 'ICMPv4' {
        Name = 'FPS-ICMP4-ERQ-In';
        Direction = 'Inbound';
        Action = 'Allow';
        Profile = 'Any';
        Enabled = $ICMP.ToString();
    }

    xFirewall 'ICMPv6' {
        Name = 'FPS-ICMP6-ERQ-In';
        Direction = 'Inbound';
        Action = 'Allow';
        Profile = 'Any';
        Enabled = $ICMP.ToString();
    }

    cAdministrativeTemplateSetting 'EnableTranscripting' {
        PolicyType = 'Machine';
        KeyValueName = 'Software\Policies\Microsoft\Windows\PowerShell\Transcription\EnableTranscripting';
        Ensure = 'Present';
        Data = '1';
        Type = 'Dword';
    }

    xWinEventLog 'Microsoft-Windows-DSC-Debug' {
        LogName = 'Microsoft-Windows-DSC/Debug';
        IsEnabled = $true;
        MaximumSizeInBytes = 2MB;
    }

}

Params -OutputPath ~\ -DisableServerManager
