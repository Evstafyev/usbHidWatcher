function Get-TimeStampLog {

    Param(
    [int]$type
    )

    switch ($type) {
    0 {"{0:MM-dd-yy}" -f (Get-Date)}
    1 {"{0:HH:mm:ss}" -f (Get-Date)}
    }    
}

$hostname = (gwmi Win32_ComputerSystem).DNSHostName

$reportLog = "C:\log\usbHid\usbHidDevices-$hostname-$(Get-TimeStampLog -type 0).txt"

$PNPserial = @()

gwmi Win32_USBDevice |
              ? {$_.Service -like 'usbccgp' -or $_.Service -like 'HidUsb'} | 
              select -ExpandProperty PNPDeviceID | 
              sls 'PID_.*?(?<=)[A-Z,0-9]\\(.*?)$' -AllMatches | 
              % {$PNPserial += $_.Matches.groups[1]}

$hidCounter = @($PNPserial).Length 

write "[$(Get-TimeStampLog -type 1)] Active USB HID devices: $hidCounter" | Out-File $reportLog -Append

foreach ($serial in $PNPserial) {
    write "[$(Get-TimeStampLog -type 1)] $serial" | Out-File $reportLog -Append
}
