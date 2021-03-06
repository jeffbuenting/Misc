﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

import-module $here\p -Force
import-module C:\Scripts\InternetExporer\InternetExplorer


$TestCases = @(
    @{
        Url = 'www.huskermax.com'
    }
)


Describe "Get-pimage" {

    # ----- Mock Get-IEWebPage 
    Mock Get-IEWebPage {
 
        $WebObject = New-Object -com "InternetExplorer.Application"
	    $WebObject.visible = $True
  	    $WebObject.Navigate($Url)

        "New Object"

        $IE = New-Object -TypeName -Property @{
            'HTML' = (  Invoke-WebRequest -uri $Url -ErrorAction Stop -Verbose:$false)
            'Url' = $Url
            'IEApp' = $Null
            'IE' = $WebOject
            'Title' = $Null
        }

write-host "closing"
       $WebObject.Quit()
        
        Write-Output $IE
    }

   
    It "<Url> : Returns Url to jpg image" -TestCases $TestCases {
        Param (
           $Url
        )

        "Url = $Url"

        $Url | Get-IEWebPage

        $Images = $IE | Get-PImages

        $images | Select-Object -first 1 | Should match 'http:\/\/.*\.jpg'
    }
}
