# -------------------------------------------------------------------------------------
# ----- Dot source the functions in the Functions folder of this module
# ----- Ignore any file that begins with @, this is a place holder of work in progress.


Get-ChildItem -path $PSScriptRoot\Functions\*.ps1 | where Name -notlike '@*' | Foreach { 
    Write-Verbose "Dot Sourcing $_.FullName"

    . $_.FullName 
}



#------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------



# -------------------------------------------------------------------------------------

Function Get-PImageJPGFFromFullURL {

<#
    .synopsis
        is there a JPG link with a full url?
#>

    [CmdletBinding()]
    Param (
        [PSCustomObject]$WebPage,

        [string[]]$ExcludedWords
    )

    Process {
        $WP = $WebPage

        #-------------------------------------------------------------------------------
            # ----- Check for full URL to Images ( jpgs )
            Write-Verbose "Get-PImages : ---------------------------- Checking for JPG with full URL"
            Write-Verbose "===== These are the Links $($WP.HTML.links | where { ( $_.href -Match 'http:\/\/.*\.jpg' ) -and ( -Not $_.href.contains('?') ) } | Select-Object -ExpandProperty HREF | out-String)"
            $WP.HTML.links | where { (( $_.href -Match 'http:\/\/.*\.jpg' ) -or ( $_.href -Match 'https:\/\/.*\.jpg' ) ) -and ( -Not $_.href.contains('?') ) } | Select-Object -ExpandProperty HREF | Foreach {
                 # ----- There is a site that has problems.  Remming to testsbj
                Write-Verbose "Is this link online? $_"
             #   if ( Test-IEWebPath -Url $_ ) {
                        Write-Verbose "***** Found : $_"
                        Write-Output $_
             #       }
             #       else {
             #           Write-Verbose "Nope"
             #   }
            }
            #if ( $FullJPGUrl ) {
            #    Write-Verbose "***** Found: $FullJPGUrl"
            #    Write-Output $FullJPGUrl
            #}

         #   if ( $WP.HTML.links | where { ( $_.href -Match 'http:\/\/.*\.jpg' ) -and ( -Not $_.href.contains('?') ) } ) { break }
    }
}

# -------------------------------------------------------------------------------------

Function Get-PImageJPGbyaddingHTTP {

<#
    .Synopsis
        Sometimes it is as easy as just adding http to the beginning of the link.
#>

    [CmdletBinding()]
    Param (
        [PSCustomObject]$WebPage,

        [string[]]$ExcludedWords
    )

    Process {
        $WP = $WebPage

        #-------------------------------------------------------------------------------
            # ----- Check to see if there are links to images ( jpgs ) - Relative Links (not full URL)
            Write-Verbose "----------------------------------------------------------------------"
            Write-Verbose "Get-PImages : ---------------------------- Checking for Links to JPGs and try adding HTML"
            Write-Verbose "----------------------------------------------------------------------"
           
            $WP.HTML.links | where href -like *.jpg | Select-Object -ExpandProperty href | Foreach {
                Write-Verbose "Image Found: $_"

                if ( Test-IEWebPath -Url "http:$_" -ErrorAction SilentlyContinue ) {
                    Write-Verbose "-----Found: http:$_"
                    Write-Output "http:$_"
                }

            }
    }

}

# -------------------------------------------------------------------------------------

Function Get-PImageJPGFFromRelativeLink {

<#
    .synopsis
        is there a relative link that has a JPG?
#>

    [CmdletBinding()]
    Param (
        [PSCustomObject]$WebPage,

        [string[]]$ExcludedWords,

        [int]$RecurseLevel = 0
    )

    Process {
        $WP = $WebPage

        #-------------------------------------------------------------------------------
            # ----- Check to see if there are links to images ( jpgs ) - Relative Links (not full URL)
            Write-Verbose "----------------------------------------------------------------------"
            Write-Verbose "Get-PImages : ---------------------------- Checking for Links to JPGs"
            Write-Verbose "----------------------------------------------------------------------"
            $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
            if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

            Write-Verbose "Website Root Path = $Root"
            $WP.HTML.links | where href -like *.jpg | Select-Object -ExpandProperty href | Foreach {
                Write-Verbose "Image Found: $Root$_"
                
                # ----- Try just adding http to the beginning and see if that is a valid URL
                Write-Verbose "Trying to add HTTP: if it begins with //"
                if ( $_.substring(0,2) -eq '//' ) {
                    Write-Verbose 'Yep // exists'
                    if ( Test-IEWebPath -Url "http:$_" -ErrorAction SilentlyContinue ) {
                        Write-Verbose "-----Found: http:$_"
                        $Pics += "http:$_"
                        Write-Output "http:$_"
                        Return
                    }
                }

                # ----- Check to see if valid URL.  Should not contain: //
                Write-Verbose 'Checking if Valid Url. Should Not Contain: // or #'
                if ( (("$Root$_" | select-string -Pattern '\/\/' -allmatches).matches.count -gt 1) -or ( ("$Root$_").contains('#') ) ) {
                    Write-Verbose "Illegal character, Getting Root"
                    $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose
                }

                Write-Verbose "Adding / to link if it needs one between Root and Link"
                if (( $_[0] -ne '/' ) -and ( $Root[$Root.length - 1] -ne '/' ) ) { $HREF = "/$_" } else { $HREF = $_ }

                # ----- Check if the image exists
                Write-Verbose "Get-PImage : Checking if image path exists and correct : $Root$HREF"
                if ( Test-IEWebPath -Url $Root$HREF -ErrorAction SilentlyContinue ) {
                        
                        # ----- if the link has a ? in it then it is not a valid image.  Shoul follow the link
                        if ( "$Root$HREF" | select-string -Pattern '\?' -Quiet ) {
                            Write-Verbose "Link contains ? : Following link"
                            Get-IEWebPage -url $Root$HREF | Get-PImages -ExcludedWords $ExcludedWords -RecurseLevel ($RecurseLevel++) -Verbose | Write-Output
                        }
                        else {
                            Write-Verbose "-----Found: $Root$HREF"
                            Write-Output $Root$HREF
                        }
                    }
                    else {
                        Write-Verbose "Get-PImage : Root/HREF is not valid.  Checking Root/JPG"
                        $JPG = $HREF | Select-String -Pattern '([^\/]+.jpg)' | foreach { $_.Matches[0].value }
                        Write-Verbose "Root/JPG : $Root$JPG"
                        if ( Test-IEWebPath -Url $Root$JPG -ErrorAction SilentlyContinue ) {
                                Write-Verbose "-----Found: $Root$JPG"
                                Write-Output $Root$JPG
                            }
                            else {
                                Write-Verbose "Oops.  Removing last domain on Root and trying that With HREF."
                                $NewRoot = $Root.substring( 0,$Root.lastindexof( '/' ) ) 
                                Write-Verbose "Does the new img Exist : $NewRoot$HREF"
                                if ( Test-IEWebPath -Url $NEwRoot$HREF -ErrorAction SilentlyContinue ) {
                                    Write-Verbose "-----Found: $NewRoot$HREF"
                                    Write-Output $NewRoot$HREF
                                }
                        }
                }
            }
    }
}

# -------------------------------------------------------------------------------------

Function Get-PImageJPGFFromHTMLLink {

<#
    .synopsis
        Check for links to image page ( ddd.htm )
#>

    [CmdletBinding()]
    Param (
        [PSCustomObject]$WebPage,

        [string[]]$ExcludedWords
    )

    Process {
        $WP = $WebPage

        #-------------------------------------------------------------------------------
            # ----- Check for links to image page ( ddd.htm )
            Write-Verbose "Get-PImages : ---------------------------- Checking for html links"

            # ----- Do not process if we have already followed one link ( stop if the URL is PHP )
            if ( $WP.Url -notmatch "\d+\.php" ) {
                $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
                if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

                $HTMLLinks = $WP.HTML.Links | where { ($_.href -like "*.html") -or ($_.HREF -match "\d+\.php") } | Select-Object -ExpandProperty href 
                 
                # ----- Check if Full Link (http) rood is the same
                $L = @()
                Foreach ( $H in $HTMLLinks ) {
                    write-Verbose "Checking $H"
                    if ( ($H -match 'http:\/\/') ) {
                            Write-Verbose "Full HTTP Url"
                            $RootForLink = Get-HTMLBaseUrl -Url $H -Verbose
                            if ( $Root -eq $RootForLink ) { 
                                    Write-Verbose "$Root = $RootForLink"
                                    $L += $H
                                }
                                Else {
                                    Write-Verbose "$Root != $RootForLink"
                            }
                        }
                        else {
                            # ----- Need to add the root here to create full url.
                            Write-Verbose "Not full HTTP Url adding root"
                            # ----- excluding these words as given that they will no produce an image
                            if ( $H -notmatch 'search' ) {
                                $L += "$Root$H"
                            }
                            else {
                                Write-Verbose "Link contained excluded word : search"
                            }
                    }

                }

                Write-Verbose `n$L

                $L | foreach {
                    Write-Verbose "`n"
                    Write-Verbose "Can I follow : $_"
                
                    $HREF = $_
                    $Root = $Null

                    if ( -not ( $_ -match 'http:\/\/' ) ) { 
                            Write-verbose "includes HTTP://"
                            $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
                            if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

                            

                            # ----- Test if webpage exists
                            if ( Test-IEWebPath -url $Root$HREF ) {
                                write-Verbose "Get-PImage : Malformed web page.  checking for //"
                                # ---- checking if // is in the middle of string
                                if ( $Root[$Root.Length()-1] -eq '/' -and $HREF[0] -eq '/' ) {
                                    Write-Verbose "Get-PImage : Removing //"
                                    $HREF = $HREF.substring[1] 
                                }

                                Write-Verbose "Checking for duplcate folders.in $Root$HREF"
                                $L = ("$Root$HREF" -SPlit '/' | Select-Object -Unique) -Join '/'


                                if ( -Not (Test-IEWebPath -Url $L) ) {
                                    Throw "Get-PImage : WebPage does not exist $L"
                                } 
                            }
                            else {
                                # ----- Here we need to check if there is a duplicate in the Url
                                Write-Verbose "Problem with Url.  Checking for duplcate folders.in $Root$HREF"
                                $L = ("$Root$HREF" -SPlit '/' | Select-Object -Unique) -Join '/'

                                Write-Verbose "New Link = $L"
                            }



                            Write-Verbose "Get-PImages : ---------------------------- Following Link: $L"
                            Try {
                                    # ----- Check if we are recursing and how deep we have gone.
                                    if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                        Write-Output ( Get-IEWebPage -Url $L -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose )
                                    }
                                }
                                Catch {
                                    # ----- If error following web link.  Try getting web root and following that
                                    $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose 
                                    Write-Verbose "Error -- Will Try : $Root$HREF "
                                    # ----- Check if we are recursing and how deep we have gone.
                                    if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                        Write-Output ( Get-IEWebPage -Url $Root$HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -ExcludedWords $ExcludedWords -Verbose )
                                    }

                            }
                        }
                        else {

                            Write-Verbose "Get-PImages : -------------------- Following Link: $HREF"


                            # Write-Output (Get-IEWebPage -url $HREF -Visible | Get-Pics -Verbose)
                            # ----- Check if we are recursing and how deep we have gone.
                            if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                
                                # ----- Here we need to check if there is a duplicate in the Url
                                Write-Verbose "Problem with Url.  Checking for duplcate folders.in $HREF"
                                $L = ("$HREF" -SPlit '/' | Select-Object -Unique) -Join '/'
                                
                                Write-Output (Get-IEWebPage -url $L -Visible | Get-PImages -RecurseLevel $RecurseLevel -ExcludedWords $ExcludedWords -Verbose)
                            }
                    }
                }
            }

    }
}

# -------------------------------------------------------------------------------------

Function Get-PImageJPGFFromThumbnailSRC {

<#
    .synopsis
       
#>

    [CmdletBinding()]
    Param (
        [PSCustomObject]$WebPage,

        [string[]]$ExcludedWords
    )

    Process {
        $WP = $WebPage


        #-------------------------------------------------------------------------------
            # ----- Checking for links where the src is a jpg thumbnail ( link does not end in html )
            Write-Verbose "checking for links where the src is a tn.jpg"
            $WP.HTML.Links | where { ( $_.innerHTML -match 'src=.*tn\.jpg' ) } | Foreach {
                if ( $_.HREF -match 'http:\/\/' ) {
                    $HREF = $_.href
                    Write-Verbose "Following Link: $HREF"
                    #Get-IEWebPage -Url $HREF -visible

                    Write-Verbose "RecurseLevel = $RecurseLevel"
                    Write-Verbose "MaxRecurseLevel = $MaxRecurseLevel"
                    # ----- Check if we are recursing and how deep we have gone.
                    if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                        $Pics = Get-IEWebPage -url $HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -ExcludedWords $ExcludedWords -Verbose
                    }

                    Write-Output $Pics
                }
                
            }

    }
}

# -------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------

