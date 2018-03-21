$configData = @{
    AllNodes = @(
        @{
            NodeName = '*';
            IcmpEnabled = 'False';
        }
        @{
            NodeName = 'localhost';
            IcmpEnabled = 'True';
            IcmpProfile = 'Any';
        }
    )
}

Configuration Params {
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    Import-DscResource -ModuleName xNetworking;
    Import-DscResource -modulename xWinEventLog;
    Import-DscResource -modulename PolicyFileEditor;

    node $AllNodes.NodeName {

        Registry 'DoNotOpenServerManagerAtLogon' {
            Key = 'HKLM:\Software\Microsoft\ServerManager';
            ValueName = 'DoNotOpenServerManagerAtLogon';
            ValueData = '1';
            ValueType = 'Dword';
        }
    
        xFirewall 'ICMPv4' {
            Name = 'FPS-ICMP4-ERQ-In';
            Direction = 'Inbound';
            Action = 'Allow';
            Profile = $node.ICMPProfile;
            Enabled = $node.ICMPEnabled;
        }

        xFirewall 'ICMPv6' {
            Name = 'FPS-ICMP6-ERQ-In';
            Direction = 'Inbound';
            Action = 'Allow';
            Profile = $node.ICMPProfile;
            Enabled = $node.ICMPEnabled;
        }

        cAdministrativeTemplateSetting 'EnableTranscripting' {
            PolicyType = 'Machine';
            KeyValueName = 'Software\Policies\Microsoft\Windows\PowerShell\Transcription\EnableTranscripting';
            Ensure = 'Present';
            Data = '1';
            Type = 'Dword';
        }

    }

}

Params -OutputPath ~\ -ConfigurationData $configData
