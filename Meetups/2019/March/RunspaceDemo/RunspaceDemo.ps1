<#
.NOTES
	================================================================================
	Filename:	RunspaceDemo.ps1

	Author:		Nigel Boulton https://nigelboulton.co.uk

	Version:	1.0.0

	Date:		10 Mar 2019

	Mod dates:

    Notes:      Script to demonstrate use and operation of PowerShell Runspaces

	================================================================================
.SYNOPSIS
    Monitors and records key network connectivity parameters for a
    collection of entities (hosts or VMs), to assist with troubleshooting
.DESCRIPTION
    On start, reads a JSON configuration file to determine which entities
    to monitor, and which IP addresses and TCP ports on these entities to
    track. Each IP address is processed by a separate thread in order to
    provide concurrency and maximise the frequency of tests, and hence
    granularity of output data

    Output is recorded to a CSV file so that it can be processed in Excel
    later for analysis and troubleshooting

    A mandatory parameter is used to specify the configuration file to read,
    and optional parameters can be used to specify the location of log and
    output files, and their name prefix. This allows the script to be run
    against multiple clusters simultaneously

    For each entity's IP address in the configuration file, a separate thread
    is instantiated, which:
    o Uses ICMP (ping) to test connectivity to the address, and records the
      latency in the output file if the test is successful, or a failure
      flag if not
    o Attempts to connect to each of the TCP ports listed against the
      address in the configuration file, and records success or failure for
      each in the output file
    o Repeats the above until the jobs have been running for a minimum
      amount of time (translated to a specified time of day)
.PARAMETER ConfigFile
    Required. Specifies the full path to the JSON configuration file to
    read. This parameter is validated, and must be a complete path to a
    file with the extension 'JSON'
.PARAMETER LogPath
    Optional. Specifies the path to the folder in which to write log
    files. This allows the script to be run against multiple clusters
    simultaneously by specifying cluster specific log folders. If this
    parameter is not used, the default is to write these files into a
    subfolder of the folder containing the script, which will be named
    'Logs'
.PARAMETER OutputPath
    Optional. Specifies the path to the folder in which to write output
    files. This allows the script to be run against multiple clusters
    simultaneously by specifying cluster specific output folders. If
    this parameter is not used, the default is to write these files into
    a subfolder of the folder containing the script, which will be named
    'Output'
.PARAMETER FileNamePrefix
    Optional. Specifies the file name prefix for all output and log
    files. This allows the script to be run against multiple clusters
    simultaneously by specifying cluster specific file names. If this
    parameter is not used, the default is to prefix these file names
    with 'RunspaceDemo' (e.g. RunspaceDemo-27-Sep-2018.csv)
.EXAMPLE
    RunspaceDemo.ps1 -ConfigFile C:\Scripts\RunspaceDemo\Cluster1.json

	Description
	-----------
    Executes the script and monitors the entities specified in the JSON
    configuration file C:\Scripts\RunspaceDemo\Cluster1.json
.EXAMPLE
    RunspaceDemo.ps1 -ConfigFile C:\Scripts\RunspaceDemo\Cluster1.json -LogPath C:\Scripts\RunspaceDemo\Logs

	Description
	-----------
    Executes the script and monitors the entities specified in the JSON
    configuration file C:\Scripts\RunspaceDemo\Cluster1.json, writing log files
    into the folder C:\Scripts\RunspaceDemo\Logs and output files to the
    default location of a subfolder of the folder containing the script,
    which will be named 'Output'
.EXAMPLE
    RunspaceDemo.ps1 -ConfigFile C:\Scripts\RunspaceDemo\Cluster1.json -OutputPath C:\Scripts\RunspaceDemo\Output

	Description
	-----------
    Executes the script and monitors the entities specified in the JSON
    configuration file C:\Scripts\RunspaceDemo\Cluster1.json, writing output
    files into the folder C:\Scripts\RunspaceDemo\Output and log files to the
    default location of a subfolder of the folder containing the script,
    which will be named 'Logs'
.EXAMPLE
    RunspaceDemo.ps1 -ConfigFile C:\Scripts\RunspaceDemo\Cluster1.json -LogPath C:\Scripts\RunspaceDemo\Logs -OutputPath C:\Scripts\RunspaceDemo\Output

	Description
	-----------
    Executes the script and monitors the entities specified in the JSON
    configuration file C:\Scripts\RunspaceDemo\Cluster1.json, writing log files
    into the folder C:\Scripts\RunspaceDemo\Logs and output files into the
    folder C:\Scripts\RunspaceDemo\Output
.EXAMPLE
    RunspaceDemo.ps1 -ConfigFile C:\Scripts\RunspaceDemo\Cluster1.json -LogPath C:\Scripts\RunspaceDemo\Logs -OutputPath C:\Scripts\RunspaceDemo\Output -FileNamePrefix Cluster1

	Description
	-----------
    Executes the script and monitors the entities specified in the JSON
    configuration file C:\Scripts\RunspaceDemo\Cluster1.json, writing log files
    into the folder C:\Scripts\RunspaceDemo\Logs and output files into the
    folder C:\Scripts\RunspaceDemo\Output. The log and output file names will
    be in the format Cluster1-dd-MMM-yyyy.*
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $true,
			   HelpMessage = 'Specify the path to the JSON configuration file to read.')]
    [ValidateScript({
        if(-not ($_ | Test-Path) ){
            throw 'Configuration file or folder does not exist.'
        }
        if(-not ($_ | Test-Path -PathType Leaf) ){
            throw 'The ConfigFile argument must be a file. Folder paths are not allowed.'
        }
        if($_ -notmatch '(\.json)'){
            throw 'The file specified in the ConfigFile argument must be of type json.'
        }
        return $true
    })]
    [System.IO.FileInfo]$ConfigFile,

    [Parameter(HelpMessage = 'Optional: Specify the path to the folder in which to write log files.')]
    [string]$LogPath = 'script_folder\Logs',

	[Parameter(HelpMessage = 'Optional: Specify the path to the folder in which to write output files.')]
    [string]$OutputPath = 'script_folder\Output',

	[Parameter(HelpMessage = 'Optional: Specify the file name prefix for all output and log files.')]
    [string]$FileNamePrefix = 'RunspaceDemo'
)

#region Functions
function Get-RTT {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )
	#===============================================================================
    # Purpose: 			To check ICMP connectivity to an IP address and return a
    #                   latency value or $Null in the event of no connectivity
    # Assumptions:
	# Effects:
	# Inputs:
	#  $IPAddress:		String containing IP address to test connectivity to
	# Calls:
    # Returns:          Integer containing latency or $Null in the event of no
    #                   connectivity
	#
    # Notes:
    #===============================================================================
    $TNCResult = (Test-NetConnection -ComputerName $IPAddress)
    if ($TNCResult.PingSucceeded) {
        return ($TNCResult).PingReplyDetails.RoundtripTime
    } else {
        return $Null
    }
}

function Get-PortStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        [Parameter(Mandatory=$true)]
        [int32]$Port
    )
	#===============================================================================
    # Purpose: 			To check whether a given TCP port is listening
    # Assumptions:
	# Effects:
	# Inputs:
    #  $IPAddress:		String containing IP address to test connectivity to
	#  $Port:		    Integer containing port to check
	# Calls:
	# Returns:          Boolean True if port is listening, False if not
    #
    # Notes:
    #===============================================================================
    $TNCResult = (Test-NetConnection -ComputerName $IPAddress -Port $Port)
    if ($TNCResult.TcpTestSucceeded) {
        return $True
    } else {
        return $False
    }
}

function Write-Log {
	param(
        [string]$LogString
    )
	#===============================================================================
    # Purpose: 			To write a string with a date and time stamp, process and
    #                   thread IDs to a log file
	# Assumptions:		$LogFile set with path to log file to write to
	# Effects:
	# Inputs:
	#  $LogString:		String to write to log file
	# Calls:
	# Returns:
	#
    # Notes:            Includes mutex so that this function can be called from
    #                   Runspaces that are writing to the same log file
	#===============================================================================
    $LogMutex = New-Object System.Threading.Mutex($false, "LogMutex")
    [void]$LogMutex.WaitOne()
    Write-Verbose "Got log mutex"
    try {
        "$(Get-Date -Format 'G') [$pid] [$([System.Threading.Thread]::CurrentThread.ManagedThreadId)] $LogString" | Out-File -Filepath $LogFile -Append -Encoding ASCII
    }
    catch {
        Write-Warning "Unable to write to log file: $Error[0]"
    }
    finally {
        [void]$LogMutex.ReleaseMutex()
        Write-Verbose "Released log mutex"
    }
    Write-Verbose $LogString
}

function Write-CSV {
	param(
        [pscustomobject]$objData
    )
	#===============================================================================
    # Purpose: 			To write data from a custom object to a CSV file with a mutex
    # Assumptions:		$OutputFile set with path to CSV file to write to
	# Effects:
	# Inputs:
	#  $objData:		Custom object containing data to write to CSV file
	# Calls:
	# Returns:
	#
    # Notes:            Includes mutex so that this function can be called from
    #                   Runspaces that are writing to the same CSV file
    #===============================================================================
    $CSVMutex = New-Object System.Threading.Mutex($false, "CSVMutex")
    [void]$CSVMutex.WaitOne()
    Write-Verbose "Got CSV mutex"
    try {
        $objData | Export-Csv -Path $OutputFile -Append -Force
    }
    catch {
        Write-Warning "Unable to write to CSV file: $Error[0]"
    }
    finally {
        [void]$CSVMutex.ReleaseMutex()
        Write-Verbose "Released CSV mutex"
    }
}
#endregion

#region Prepare
# Start of script
#requires -Version 3.0
Set-StrictMode -Version 3

# Get containing folder for script to locate supporting files
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# User configurable variables
$RunJobsForMins = 1 # Jobs will not be restarted if they have been running for longer than this
# $MaxThrottleLimit = 100 # Cap the number of Runspaces running concurrently in the Runspace Pool. The throttle limit is set by the number of addresses in the JSON config file up to this maximum
#endregion

#region Logging
# Set up logging
if ($LogPath -eq 'script_folder\Logs') { # Default from optional script parameter. Default parameter value is visible in Get-Help for script
    $LogPath = "$ScriptPath\Logs" # Workaround as you can't use $MyInvocation in a parameter default
}
if (-not(Test-Path $LogPath)) {
	New-Item $LogPath -ItemType Directory | Out-Null
}
$LogFile = Join-Path $LogPath "$FileNamePrefix-$(Get-Date -Format 'dd-MMM-yyyy').log"
Write-Verbose "Log file is $LogFile"
Write-Log "Processing started on server $Env:COMPUTERNAME"

# Record the path to the JSON config file in the log file for troubleshooting
# $ConfigFile is set by a mandatory, validated script parameter
Write-Log "Config file is $ConfigFile"
#endregion

#region Output
# Set up output
if ($OutputPath -eq 'script_folder\Output') { # Default from optional script parameter. Default parameter value is visible in Get-Help for script
    $OutputPath = "$ScriptPath\Output" # Workaround as you can't use $MyInvocation in a parameter default
}
if (-not(Test-Path $OutputPath)) {
    New-Item $OutputPath -ItemType Directory | Out-Null
}
$OutputFile = Join-Path $OutputPath "$FileNamePrefix-$(Get-Date -Format 'dd-MMM-yyyy').csv"
Write-Log "Output file is $OutputFile"
#endregion

#region Config
# Set the time of day that all jobs should end by. This is done to reduce the possibility of long-running jobs
# consuming excessive server resource, and also in an attempt to avoid potential file locking conflicts by ensuring
# that the previous run of the script has completed before the scheduled task that starts it again triggers
$dtmJobsEndTime = Get-Date((Get-Date).AddMinutes($RunJobsForMins).ToLongTimeString())

# Read the entity data from the JSON config file
$Data = Get-Content $ConfigFile | ConvertFrom-Json

# Count the number of addresses in the JSON file to set the Runspace Pool throttle limit
$AddressCount = @($Data.entities.addresses).Count
$throttleLimit = $AddressCount
# if ($AddressCount -gt $MaxThrottleLimit) {
#     $throttleLimit = $MaxThrottleLimit # This is an attempt to avoid runaway threads. If this is reached, some addresses won't be monitored
# }
#endregion

#region Prepare CSV
if (-not(Test-Path $OutputFile)) { # If the output file for today doesn't exist
    # This is done to allow subsequent runs of the script on a given day to append to the existing CSV file
    # Construct a CSV file with the following headers:
    # Time,ThreadID,Entity,IPAddress,Latency,Port1,Port2,...,Portn
    # Get the full list of possible ports specified in the JSON file. This is required to set the CSV headers accordingly
    $UniquePorts = ($Data.entities.addresses.ports | Sort-Object * -Unique) # Sorted unique list of possible ports
    # Put everything in a custom object
    $objTemp = New-Object PSObject # Temporary custom object to be converted to CSV format
    $objTemp | Add-Member -MemberType NoteProperty -Name Date -Value $Null
    $objTemp | Add-Member -MemberType NoteProperty -Name ThreadID -Value $Null
    $objTemp | Add-Member -MemberType NoteProperty -Name Entity -Value $Null
    $objTemp | Add-Member -MemberType NoteProperty -Name IPAddress -Value $Null
    $objTemp | Add-Member -MemberType NoteProperty -Name Latency -Value $Null
    foreach ($Port in $UniquePorts) {
        $objTemp | Add-Member -MemberType NoteProperty -Name $Port -Value $Null
    }
    # Convert the object to CSV and strip the resultant empty line
    $Headers = $objTemp | ConvertTo-CSV -NoTypeInformation | Select-Object -First 1
    # Write to a file
    $Headers | Set-Content -Path $OutputFile
}
#endregion

#region Initialise Runspace Pool
[void][runspacefactory]::CreateRunspacePool()

# Set up an initial session state object for the Runspace
$initialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

# Get the function definition for the function to add to the Runspace: Write-Log
$functionDefinition = Get-Content function:\Write-Log
$functionEntry = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList "Write-Log", $functionDefinition
# ...add it to the initial session state object
$initialSessionState.Commands.Add($functionEntry)

# Get the function definition for the function to add to the Runspace: Write-CSV
$functionDefinition = Get-Content function:\Write-CSV
$functionEntry = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList "Write-CSV", $functionDefinition
# ...add it to the initial session state object
$initialSessionState.Commands.Add($functionEntry)

# Get the function definition for the function to add to the Runspace: Get-RTT
$functionDefinition = Get-Content function:\Get-RTT
$functionEntry = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList "Get-RTT", $functionDefinition
# ...add it to the initial session state object
$initialSessionState.Commands.Add($functionEntry)

# Get the function definition for the function to add to the Runspace: Get-PortStatus
$functionDefinition = Get-Content Function:\Get-PortStatus
$functionEntry = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList "Get-PortStatus", $functionDefinition
# ...add it to the initial session state object
$initialSessionState.Commands.Add($functionEntry)

Write-Log ('Runspace Pool throttled to ' + $throttleLimit + ' concurrent threads')
# Create a Runspace Pool using the initial session state object set up above
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,$throttleLimit,$initialSessionState,$Host)
$RunspacePool.Open()
#endregion

#region Script block
# Script block to run in each Runspace. Note that a param() statement is required to support passing in variables, see
# https://blogs.technet.microsoft.com/heyscriptingguy/2015/11/27/beginning-use-of-powershell-runspaces-part-2/
$ScriptBlock = {
    param (
        $VerbosePreference,
        [datetime]$EndTime,
        [string]$LogFile,
        [string]$OutputFile,
        [string]$ComputerName,
        [string]$IPAddress,
        [int32[]]$Ports
    )

    $ThreadID = [System.Threading.Thread]::CurrentThread.ManagedThreadId
    Write-Verbose "Starting Thread ID $ThreadId"
    $StartTime = (Get-Date)
    $LoopDurationSec = 0

    Write-Log "Job monitoring $IPAddress on $ComputerName has Thread ID $ThreadId and will not repeat after $(Get-Date($EndTime) -Format 'G')"
    while ((Get-Date) -lt $EndTime.AddSeconds(-$LoopDurationSec)) { # Subtract the duration of the last loop iteration from the end time to minimise the chance over overrunning
        # For debugging
        ##Write-Log "Updated end time for job monitoring $IPAddress on $ComputerName is $(Get-Date($EndTime.AddSeconds(-$LoopDurationSec)) -Format 'G')"
        $LoopStartTime = (Get-Date)
        $RTT = (Get-RTT -IPAddress $IPAddress)
        # For debugging
        if ($RTT -ne $null) {
            Write-Log "Latency for $IPAddress ($ComputerName) is $RTT mS"
        } else {
            Write-Log "WARNING: $IPAddress ($ComputerName) is not responding to ICMP requests"
        }
        if ($RTT -eq $null) {
            $RTT = 'Fail'
        }

        # Put everything in a custom object
        $objTemp = New-Object PSObject # Temporary custom object to go into the CSV file
        $objTemp | Add-Member -MemberType NoteProperty -Name Date -Value (Get-Date -Format 'G')
        $objTemp | Add-Member -MemberType NoteProperty -Name ThreadID -Value $ThreadId
        $objTemp | Add-Member -MemberType NoteProperty -Name Entity -Value $ComputerName
        $objTemp | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress
        $objTemp | Add-Member -MemberType NoteProperty -Name Latency -Value $RTT
        foreach ($Port in $Ports) {
            $PortStatus = Get-PortStatus -IPAddress $IPAddress -Port $Port
            if ($PortStatus -eq $True) {
                # For debugging
                Write-Log "Port $Port on $IPAddress ($ComputerName) listening"
                $objTemp | Add-Member -MemberType NoteProperty -Name $Port -Value 'OK'

            } else {
                # For debugging
                Write-Log "WARNING: Port $Port on $IPAddress ($ComputerName) closed"
                $objTemp | Add-Member -MemberType NoteProperty -Name $Port -Value 'Fail'
            }
        }
        # Write object out to CSV file
        Write-CSV -objData $objTemp

        $LoopDurationSec = (New-TimeSpan -Start $LoopStartTime -End (Get-Date)).TotalSeconds
        # For debugging
        ##Write-Log "The last loop took $LoopDurationSec seconds"
    }
    $TimeRunning = New-TimeSpan -Start $StartTime -End (Get-Date)
    Write-Log "Job monitoring $IPAddress on $ComputerName ending"
    # For debugging
    ##Write-Log "Thread $ThreadID was running for $($TimeRunning.TotalSeconds) seconds"
} # End of $ScriptBlock
#endregion

#region Create jobs
# Create an Array List to hold jobs. Jobs in this list are termed 'remaining', meaning they are either running
# or waiting to run
$Jobs = New-Object System.Collections.ArrayList

foreach ($Entity in $Data.entities) {
    foreach ($Address in $Entity.addresses){
        # Create a Runspace for each IP address belonging to each entity (CVM or host) to maximise concurrency of tests
        # See https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.powershell?view=powershellsdk-1.1.0
        $PowerShell = [System.Management.Automation.PowerShell]::Create()
        $PowerShell.RunspacePool = $RunspacePool

        # Hash table of parameters is used to pass variables into the Runspace. The script block must have a
        # corresponding param() statement, see https://blogs.technet.microsoft.com/heyscriptingguy/2015/11/27/beginning-use-of-powershell-runspaces-part-2/
        $ParamList = @{
            VerbosePreference = $VerbosePreference
            Endtime = $dtmJobsEndTime
            LogFile = $LogFile
            OutputFile = $OutputFile
            ComputerName = $Entity.name
            IPAddress = $Address.ipaddress
            Ports = $Address.ports
        }

        # Add the script to run in the Runspace - include AddParameters to be able to pass variables in
        [void]$PowerShell.AddScript($ScriptBlock).AddParameters($ParamList)

        # Start the job
        $Handle = $PowerShell.BeginInvoke()
        $objTemp = New-Object PSObject # Temporary custom object to go into the Array List
        $objTemp | Add-Member -MemberType NoteProperty -Name PowerShell -Value $PowerShell
        $objTemp | Add-Member -MemberType NoteProperty -Name Handle -Value $Handle
        # Save the job in the Array List. We will use this to clean up later
        [void]$Jobs.Add($objTemp)
        Write-Verbose ("Remaining jobs: {0}" -f @($Jobs | Where-Object {$_.handle.iscompleted -ne $True}).Count)
        Write-Verbose ("Available Runspaces in Runspace Pool: {0}" -f $RunspacePool.GetAvailableRunspaces())
    }
}
#endregion

#region Wait for completion
# Wait for all jobs to finish
$LastJobCount = 0
while (@($Jobs | Where-Object {$_.handle.iscompleted -ne $True}).Count) {
    $JobCount = @($Jobs | Where-Object {$_.handle.iscompleted -ne $True}).Count
    if ($JobCount -ne $LastJobCount) {
        Write-Host "There are $JobCount remaining jobs" -ForegroundColor Green
        Write-Log "There are $JobCount remaining jobs"
        $LastJobCount = $JobCount
    }
    Start-Sleep -Milliseconds 200
}
#endregion

#region Clean up
# Dispose of the Runspace objects
$Return = $Jobs | ForEach-Object {
    $_.PowerShell.EndInvoke($_.handle)
    $_.PowerShell.Dispose()
}
$Jobs.Clear()
#endregion

Write-Log 'Processing completed'
Write-Host 'Processing completed' -ForegroundColor Green