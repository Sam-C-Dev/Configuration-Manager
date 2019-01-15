<#
.SYNOPSIS
    Get warranty information for a Lenovo system.
.DESCRIPTION
    This script will gather the warranty information for a Lenovo system.
.NOTES
    Script name: Get-LenovoWarrantyInformation.ps1
    Author:      Odd-Magne Kristoffersen
    Contact:     @oddmk79
    DateCreated: 2019-01-15
.SOURCES
    https://www.scconfigmgr.com/2015/03/21/get-lenovo-warranty-information-with-powershell/
    https://forums.lenovo.com/t5/Lenovo-Technologies/Warranty-API/td-p/3484953
#>
    $Manufacturer = Get-WmiObject -Class Win32_BIOS | Select-Object -expand Manufacturer
    if ($Manufacturer -notmatch "Lenovo")                
        {
        Write-Warning "Not a Lenovo system"
        }
    else
    {
        $SerialNumber = Get-WmiObject -Class Win32_BIOS | Select-Object -expand SerialNumber
        $URL = "https://ibase.lenovo.com/POIRequest.aspx"
        $Method = "POST"
        $Header = @{ "Content-Type" = "application/x-www-form-urlencoded" }
        $Body = "xml=<wiInputForm source='ibase'><id>LSC3</id><pw>IBA4LSC3</pw><product></product><serial>$SerialNumber</serial><wiOptions><machine/><parts/><service/><upma/><entitle/></wiOptions></wiInputForm>"
        $RequestResult = Invoke-RestMethod -Method $Method -Uri $URL -Body $Body -Headers $Header

            $WarrantyInformation = [PSCustomObject]@{
            Type = $RequestResult.wiOutputForm.warrantyInfo.machineinfo.type
            Model = $RequestResult.wiOutputForm.warrantyInfo.machineinfo.model
            Product = $RequestResult.wiOutputForm.warrantyInfo.machineinfo.product
            SerialNumber = $RequestResult.wiOutputForm.warrantyInfo.machineinfo.serial
            StartDate = $RequestResult.wiOutputForm.warrantyInfo.serviceInfo.warstart[0]
            ExpirationDate = $RequestResult.wiOutputForm.warrantyInfo.serviceInfo.wed[0]
            Location = $RequestResult.wiOutputForm.warrantyInfo.serviceInfo.countryDesc[0]
            Description = $RequestResult.wiOutputForm.warrantyInfo.serviceInfo.sdfDesc[0]
            }
    Write-Output $WarrantyInformation
}