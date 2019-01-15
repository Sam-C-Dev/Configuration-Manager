<#
.SYNOPSIS
    Get warranty information for a Lenovo system.
.DESCRIPTION
    This script will gather the warranty information for a Lenovo system.
.EXAMPLE
    .\Invoke-LenovoWarrantyCheck.ps1
.NOTES
    Script name: Invoke-LenovoWarrantyCheck.ps1
    Author:      Odd-Magne Kristoffersen
    Contact:     @oddmk79
    DateCreated: 2019-01-15
.SOURCES
    https://www.scconfigmgr.com/2015/03/21/get-lenovo-warranty-information-with-powershell/
    https://forums.lenovo.com/t5/Lenovo-Technologies/Warranty-API/td-p/3484953
#>

    $SerialNumber = Get-WmiObject -Class Win32_BIOS | Select-Object -expand SerialNumber
    $URL = "https://ibase.lenovo.com/POIRequest.aspx"
    $Method = "POST"
    $Header = @{ "Content-Type" = "application/x-www-form-urlencoded" }
    $Body = "xml=<wiInputForm source='ibase'><id>LSC3</id><pw>IBA4LSC3</pw><product></product><serial>$SerialNumber</serial><wiOptions><machine/><parts/><service/><upma/><entitle/></wiOptions></wiInputForm>"
    $RequestResult = Invoke-RestMethod -Method $Method -Uri $URL -Body $Body -Headers $Header

    $RegistryPath = "HKLM:\SOFTWARE\WarrantyInformation"
    New-Item -Path $RegistryPath –Force | Out-Null

    New-ItemProperty -Path $RegistryPath -Name Type -Value $RequestResult.wiOutputForm.warrantyInfo.machineinfo.type -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name Model -Value $RequestResult.wiOutputForm.warrantyInfo.machineinfo.model -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name Product -Value $RequestResult.wiOutputForm.warrantyInfo.machineinfo.product -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name SerialNumber -Value $RequestResult.wiOutputForm.warrantyInfo.machineinfo.serial -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name StartDate -Value $RequestResult.wiOutputForm.warrantyInfo.serviceInfo.warstart[0] -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name ExpirationDate -Value $RequestResult.wiOutputForm.warrantyInfo.serviceInfo.wed[0] -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name Location -Value $RequestResult.wiOutputForm.warrantyInfo.serviceInfo.countryDesc[0] -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name Description -Value $RequestResult.wiOutputForm.warrantyInfo.serviceInfo.sdfDesc[0] -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $RegistryPath -Name WarrantyCheckDate -Value (Get-Date -Format yyyy-MM-dd) -PropertyType String -Force | Out-Null
