Function Get-PImageJPGFromSRC {

<#
    .synopsis
        Does a SRC tag have a jpg file
#>

    [CmdletBinding()]
    Param (
        [PSCustomObject]$WebPage,

        [string[]]$ExcludedWords
    )

    Process {
        $WP = $WebPage
        $Pics = @()

        write-Verbose "Excludedwords = $($ExcludedWords | out-string)"

        #-------------------------------------------------------------------------------
        # ----- Images on the page.
        Write-verbose "Get-PImages : ---------------------------- Checking for images on page."

        $WP.HTML.images | where src -match '\d*\.jpg' | foreach {
            $SRC = $_.SRC

            Write-Verbose "Get-PImages : Examining: $($_.src)"

            # ----- Check if any excluded word is in the string.
            if ( $_.src | Select-String -Pattern $ExcludedWords -NotMatch ) {                                      

                    # ----- Match was 
                    Write-Verbose "Get-PImage : ----- $SRC -- Does the image start with HTTP?" 
                    if ( ( $_.SRC -Match 'http:\/\/.*\/\d*\.jpg' ) -or ($_.SRC -Match 'http:\/\/.*\d*\.jpg' ) -or ( $_.SRC -Match 'https:\/\/.*\/\d*\.jpg' ) -or ($_.SRC -Match 'https:\/\/.*\d*\.jpg' ) ) { 
                            Write-Verbose "Get-PImages : returning full JPG Url $($_.SRC)"
                      
                            $Pics += $_.SRC
                            Write-Verbose "Get-PImages : -----Found: $($_.SRC)"
                            Write-Output $_.SRC 
                    }

                    Write-Verbose "Get-PImage : ----- $($_.src) -- No HTTP or HTTPS"                  
                    If ( ($_.SRC -notmatch 'http:\/\/.*' ) -and ($_.SRC -notmatch 'https:\/\/.*') ) {
                            
                                $PotentialIMG = $_.SRC
                            
                                # ----- Check if the link contains /tn_.  if so remove and process image
                                if ( $PotentialIMG.Contains( "\/tn_") ) {
                                    $PotentialIMG = $PotentialIMG.Replace( '/tn_','/')
                                }

                                # ----- Try just adding http to the beginning and see if that is a valid URL
                                Write-Verbose "Trying to add HTTP: if it begins with //"
                                if ( $PotentialIMG.substring(0,2) -eq '//' ) {
                                    Write-Verbose 'Yep // exists'
                                    if ( Test-IEWebPath -Url "http:$PotentialIMG" -ErrorAction SilentlyContinue ) {
                                        Write-Verbose "-----Found: http:$PotentialIMG"
                                        $Pics += "http:$PotentialIMG"
                                        Write-Output "http:$PotentialIMG"
                                        Return
                                    }
                                }


                                Write-Verbose "Get-PImages : JPG Url is relitive path.  Need base/root."
                                $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
                                if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

                                # ----- Check to see if valid URL.  Should not contain: //
                                if ( ("$Root$_" | select-string -Pattern '\/\/' -allmatches).matches.count -gt 1 )  {
                                    Write-Verbose "Get-PImages : Illegal character, Getting Root"
                                    $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose
                                }

                                Write-Verbose "Adding / to link if it needs one between Root and Link"
                                if (( $PotentialIMG[0] -ne '/' ) -and ( $Root[$Root.length - 1] -ne '/' ) ) { $PotentialIMG = "/$PotentialIMG" } 
                           

                                # ----- Checking if image is a valid path
                                # $URL = "$Root$($_.SRC)"
                                #  Write-Verbose "+++++++++++$Root$($_.SRC)"
                                if ( Test-IEWebPath -Url "$Root$PotentialIMG" -ErrorAction SilentlyContinue ) {
                                        $Pics += "$Root$PotentialIMG"

                                        Write-Verbose "-----Found: $Root$PotentialIMG"
                                        Write-Output "$Root$PotentialIMG"
                                    }
                                    else {
                                        Write-Verbose "Get-PImage : Root/SRC is not valid.  Checking Root/JPG"
                                        $JPG = $PotentialIMG | Select-String -Pattern '([^\/]+.jpg)' | foreach { $_.Matches[0].value }
                                        if ( Test-IEWebPath -Url $Root$JPG ) {
                                            Write-Verbose "-----Found: $Root$JPG"
                                            Write-Output $Root$JPG
                                        }
                                }
                            }
                            Else {
                                Write-Verbose "Get-PImages :  Image not found $($_.SRC)"
                                write-verbose "$_.SRC"
                                write-Verbose "fluffernuter"

                        
                            
                    }
                }
                else {
                    Write-Verbose "$($_.SRC) matches:"
                    Write-Verbose "Excluded Pattern = $(($_.src | Select-String -Pattern $ExcludedWords).Pattern ) "
            }

        }

        Write-Output $Pics

    }
}