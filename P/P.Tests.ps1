$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

import-module $here\p -Force

Describe "Get-pimage" {

    # ----- Mock Get-IEWebPage 
    Mock Get {

        $WebObject = New-Object -com "InternetExplorer.Application"
	    $WebObject.visible = $true 
  	    $WebObject.Navigate($Url)

        $IE = New-Object -TypeName -Property @{
            'HTML' = (  Invoke-WebRequest -uri $Url -ErrorAction Stop -Verbose:$false)
            'Url' = $Url
            'IEApp' = $Null
            'IE' = $WebOject
            'Title' = $Null
        }
    }

    It "Returns Url to jpg image" {
        $Images = $IE | Get-PImages

        ($images | Select-Object -first 1 ) -match 'http:\/\/.*\.jpg'
    }
}
