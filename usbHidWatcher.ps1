<#
.SYNOPSIS
    The script collects PNPId of connected usb devices in local log file.
.DESCRIPTION
    The script collects unique identifiers for USB devices 
    of classes Microsoft HID (HidUsb) and USB Generic (usbccgp)
    using WMI Win32_UsbDevice class and writes it to a log file locally.
    This solution is used as an addition to the local zabbix agent 
    user parameters configuration for inventory and security tasks.
.Notes
    File name: usbHidWatcher.ps1
.OUTPUTS
    Log file: C:\log\usbHid\<MM-dd>\usbHidDevices-<hostname>-<MM-dd-yy>
.NOTES
    Version:        2.0
    Author:         Alex Evstafiev
    Creation Date:  01.08.2019
    Purpose/Change: Initial script development
    PS Version: 5.0   
#>

function Get-TimeStamp {
    <#
    .SYNOPSIS
        Outputs custom date format
    .DESCRIPTION
        Outputs two different date formats:
        -type "0" like 12-19, current date MM-yy format
        -type "1" like 12-31-19, current date MM-dd-yy format
        -type "2" like 12:00:00, current time HH:mm:ss, 24h format
        
    #>
    Param(
    [int]$type
    )

    switch ($type) {
    0 {"{0:MM-yy}" -f (Get-Date)}
    1 {"{0:MM-dd-yy}" -f (Get-Date)}
    2 {"{0:HH:mm:ss}" -f (Get-Date)}
    }    
}

$getHostName = (gwmi win32_computersystem).dnshostname

$getUsername = (gwmi win32_computersystem).username

$shortLogPath = "C:\log\usbHid\$(Get-TimeStamp -type 0)\"

$logFileName = "usbHidDevices-$getHostName-$(Get-TimeStamp -type 1).txt"

$fullLogPath = Join-Path -Path $shortLogPath -ChildPath $logFileName

$testPath = Test-Path $shortLogPath

if (!$testPath) {

    New-Item -Path $shortLogPath -ItemType Directory -Force

}

$pnpId = @()

gwmi win32_usbdevice |
    ? {
        $_.Service -like 'usbccgp' -or 
        $_.Service -like 'HidUsb'
      } | 
      select -exp PNPDeviceID | 
      sls 'PID_.*?(?<=)[A-Z,0-9]\\(.*?)$' -AllMatches | 
    % {
        $pnpId += $_.Matches.groups[1]
       }

$hidCounter = @($pnpId).Length 

write "[$(Get-TimeStamp -type 2)] Logged in user: $getUsername" | Out-File $fullLogPath -Append

write "[$(Get-TimeStamp -type 2)] Active USB HID and generic devices: $hidCounter" | Out-File $fullLogPath -Append

foreach ($id in $pnpId) {
    write "[$(Get-TimeStamp -type 2)] $id" | Out-File $fullLogPath -Append
}
