#Get Event from Azure Metadata Service
$eventType = (Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri "http://169.254.169.254/metadata/scheduledevents?api-version=2020-07-01").Events.EventType
if ($eventType -eq 'Terminate'){
    #Get Installation
    function Get-GatewayInstalled([string]$name){
        $installedSoftwares = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        foreach ($installedSoftware in $installedSoftwares){
            $displayName = $installedSoftware.GetValue("DisplayName")
            if (($displayName -eq "$name Preview") -or ($displayName -eq $name)){
                return $true
            }
        }
        return $false
    }

    #Uninstall it
    if (Get-GatewayInstalled("Microsoft Integration Runtime")){
        [void](Get-WmiObject -Class Win32_Product -Filter "Name='Microsoft Integration Runtime Preview' or Name='Microsoft Integration Runtime'" `
                -ComputerName $env:COMPUTERNAME).Uninstall()
        Write-Host "Microsoft Integration Runtime has been uninstalled"
    } else {
        Write-Host "Microsoft Integration Runtime is not installed"
    }    
}

