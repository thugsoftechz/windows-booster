# clean temp folder
Get-ChildItem -Path "C:\Windows\Temp" *.* -Recurse | Remove-Item -Force -Recurse

# restart windows 
taskkill /f /im explorer.exe

#ultimate perfomance 
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

# defrag

analysis = Get-DefragAnalysis -Driveletter C: -Computername chi-dc01,chi-dc02,chi-dc03
#starting

Get-WmiObject win32_volume -filter "driveletter='c:'" -ComputerName chi-dc02 | Invoke-WmiMethod -Name Defrag


#remove prefetch
Get-ChildItem -Path "C:\Windows\Prefetch" *.* -Recurse | Remove-Item -Force -Recurse


#get update
Install-Module PSWindowsUpdate -A
Get-WindowsUpdate
Install-WindowsUpdate -A



# disable startup apps
function Disable-Startups {
    [CmdletBinding()]
    Param(
        [parameter(DontShow = $true)]
        $32bit = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        [parameter(DontShow = $true)]
        $32bitRunOnce = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        [parameter(DontShow = $true)]
        $64bit = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
        [parameter(DontShow = $true)]
        $64bitRunOnce = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce",
        [parameter(DontShow = $true)]
        $currentLOU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        [parameter(DontShow = $true)]
        $currentLOURunOnce = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )

    Begin {
        $disableList = @(
            "iTunesHelper",
            "Cisco AnyConnect Secure Mobility Agent for Windows",
            "Ccleaner Monitoring",
            #"SunJavaUpdateSched",
            "Steam",
            "Discord"
        )
        New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-Null
        $startups = Get-CimInstance Win32_StartupCommand | Select-Object Name,Location
    }
    Process {
        foreach ($startUp in $startUps){
            if ($startUp.Name -in $disableList){
                $number = ($startUp.Location).IndexOf("\")
                $location = ($startUp.Location).Insert("$number",":")
                Write-Output "Disabling $($startUp.Name) from $location)"
                #Remove-ItemProperty -Path "$location" -Name "$($startUp.name)" 
            }
        }

        $regStartList = Get-ItemProperty -Path $32bit,$32bitRunOnce,$64bit,$64bitRunOnce,$currentLOU,$currentLOURunOnce | Format-List
    }
    End {}
}


#upgarde 

Reboot-Computer

