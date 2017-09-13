Function Get-PImages {

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [PSCustomObject[]]$WebPage,

        [int]$RecurseLevel = 0,

        [int]$MaxRecurseLevel = 1
    )

    Begin {
        # ----- List of words to ignore if they are part of an image link
        $ExcludedWords = '\d*x\d*\.jpg','\d\d_\d\d\.jpg',
                    '-set.jpg',
                    '0003.jpg','0c257637.jpg',
                    '22962675.jpg','31504128.jpg','31273357.jpg','346.jpg','5009.jpg','/17_','/7_','468x60','468x100d.jpg','45fl.jpg',
                    '5002.jpg',
                    '60_001.jpg','6960553.jpg','6833789.jpg','6833789.jpg','6732258.jpg',
                    '7112430','7060344.jpg','7083247.jpg','7113434','400.jpg','728_4.jpg',
                    '80-7.jpg',
                    '98.jpg',
                    'ajinx.jpg','akiss.jpg','ally1.jpg','anna','atk','allstarban.jpg','lstar.jpg','ahmc.jpg','ann5.jpg','antonella.jpg','avatar.jpg','ashlee.jpg',
                    '/b/','backtohome','backtohome','baesnaps.jpg','banner','bella.jpg','bellaclu','big.jpg','bmarie.jpg','bn.jpg','bookmark','box_title_main_menu','brooklynna.jpg','bulkpic','bianca1.jpg',
                    'baberoad.jpg','bann-01b.jpg',
                    '/cm/','chase.jpg','cosmid.jpg','cake.jpg','candygirl.jpg','chey.jpg','camsodagirl.jpg','CXiXwn.jpg',
                    'nymoody.jpg','ddfyes.jpg','dannii.jpg','dice.jpg',
                    'eyr.jpg','ecole.jpg','eclub.jpg','egasson.jpg','edildo.jpg','esperanza.jpg','evilangelmini2',
                    'friends','front','frontpage','footer','fowler.jpg','ftvm.jpg','freckles.jpg','fsc.jpg','freecams.jpg','folio.jpg','-f2.jpg',
                    'gallery-','gallary_','gemma.jpg','girls/','girlsway.jpg','gainsize.jpg','glamm.jpg','glamourshow.jpg',
                    'himg.jpg','header','header2','hor_','high.jpg','hahn.jpg','hayleysec.jpg','hayleys.jpg',
                    'iblowjob.jpg','/index_','imgs/','/img','images/15','inude.jpg','ingerie.jpg',
                    'jenann.jpg','jay.jpg',
                    'kay.jpg','kris','karinew.jpg','khandi.jpg','kimber.jpg','kissban.jpg','kiraqueen.jpg','kendrick.jpg',
                    'littlepics','lia.jpg','lily.jpg','live1.jpg','logo','louise.jpg','lflash.jpg','lucyv.jpg','ley.jpg','ldmyes.jpg','laurenp.jpg',
                    'main','madden.jpg','mac*kenzies*\d*.jpg','maren.jpg','marxs.jpg','monicam.jpg','morazzia.jpg','m1.nsimg.net','myboobs.jpg','mercedez.jpg','more-galleries.jpg','monroe.*\.jpg',
                    'natashaban.jpg','newupdates','nfbusty.jpg','ngg','nov','ntyler.jpg','nise.jpg','netis.jpg',
                    'oct','offer','officefan.jpg','orig_\d*\.jpg','olivia.jpg',
                    'paris.jpg','paysite.jpg','paysite_icons','pinup.jpg','pinupfiles.jpg','peta.jpg',
                    'rain.jpg','ridol.jpg','robyn.jpg','rta.jpg','realgirls.jpg',
                    'sascha','scorelandyes.jpg','Screen-Shot','search','seeher.jpg','separator','simsnew.jpg','siri.jpg','slide','small','smclub.jpg','snude.jpg','sophiedee1.jpg','sophy.jpg','spinchix.jpg','spring.jpg','stasyq.jpg','stmac.jpg','sdavies.jpg',
                    'spunky.jpg','_sarina.jpg','smith.jpg',
                    't.jpg','tanude.jpg','Template','tgp','thumb','tk_','tn.jpg','tn2','tn_','/th','/tn','tn-','tessa.jpg','tasia.jpg','totemnewyes3.jpg','trueamateur.jpg','typein.jpg',
                    'upload/',
                    'vanessa-black-lace-one-piece-bella-club-2.jpg','vertical.jpg','sarinavalentina.jpg',
                    'webcam','webcamyes.jpg','wellhello.jpg','wifey.jpg','withher.jpg','ww2.jpg',
                    'yea.jpg','ytease.jpg','ycake.jpg','ywinters.jpg','yesboobs.jpg','yjay.jpg',
                    'zara4.jpg','zishy.jpg'
    }
   

    process {
        Write-Verbose "Get-PImage : Recurse Level : $RecurseLevel"
        Write-Verbose "Adding recurse level"
        $RecurseLevel ++

        ForEach ( $WP in $WebPage ) {

            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"

            Write-Verbose "Get-PImages : Getting Images from $($WP.URL)..."

            $Pics = @()

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
                        if ( ( $_.SRC -Match 'http:\/\/.*\/\d*\.jpg' ) -or ($_.SRC -Match 'http:\/\/.*\d*\.jpg' ) ) { 
                                Write-Verbose "Get-PImages : returning full JPG Url $($_.SRC)"
                      
                                $Pics += $_.SRC
                                Write-Verbose "Get-PImages : -----Found: $($_.SRC)"
                                Write-Output $_.SRC 
                        }

                        Write-Verbose "Get-PImage : ----- $($_.src) -- No HTTP"                  
                        If ( ($_.SRC -notmatch 'http:\/\/.*' ) ) {
                            
                                    $PotentialIMG = $_.SRC
                            
                                    # ----- Check if the link contains /tn_.  if so remove and process image
                                    if ( $PotentialIMG.Contains( "\/tn_") ) {
                                        $PotentialIMG = $PotentialIMG.Replace( '/tn_','/')
                                    }

                                    Write-Verbose "Get-PImages : JPG Url is relitive path.  Need base/root."
                                    $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
                                    if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

                                    # ----- Check to see if valid URL.  Should not contain: //
                                    if ( ("$Root$_" | select-string -Pattern '\/\/' -allmatches).matches.count -gt 1 )  {
                                        Write-Verbose "Get-PImages : Illegal character, Getting Root"
                                        $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose
                                    }

                           

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
                        Write-Verbose "Excluded = $($_.src | Select-String -Pattern $ExcludedWords -NotMatch | Out-String ) "
                }

            }

           
            if ( $Pics ) { Break }
            
            #-------------------------------------------------------------------------------
            # ----- Check for full URL to Images ( jpgs )
            Write-Verbose "Get-PImages : ---------------------------- Checking for JPG with full URL"
            Write-Verbose "===== These are the Links $($WP.HTML.links | where { ( $_.href -Match 'http:\/\/.*\.jpg' ) -and ( -Not $_.href.contains('?') ) } | Select-Object -ExpandProperty HREF | out-String)"
            $WP.HTML.links | where { ( $_.href -Match 'http:\/\/.*\.jpg' ) -and ( -Not $_.href.contains('?') ) } | Select-Object -ExpandProperty HREF | Foreach {
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
            
            #-------------------------------------------------------------------------------
            # ----- Check to see if there are links to images ( jpgs ) - Relative Links (not full URL)
            Write-Verbose "Get-PImages : ---------------------------- Checking for Links to JPGs"
            $Root = Get-HTMLBaseUrl -Url $WP.Url -Verbose
            if ( -Not $Root ) { $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose }

            Write-Verbose "Website Root Path = $Root"
            $WP.HTML.links | where href -like *.jpg | Select-Object -ExpandProperty href | Foreach {
                Write-Verbose "Image Found: $Root$_"
                
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
                        Write-Verbose "-----Found: $Root$HREF"
                        Write-Output $Root$HREF
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
            
            if ( $WP.HTML.links | where href -like *.jpg ) { break }

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
                    if ( $H -match 'http:\/\/' ) {
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
                            Write-Verbose "Not full HTTP Url"
                            $L += $H
                    }

                }

                Write-Verbose `n$L

                $L | foreach {
                    Write-Verbose "`n"
                    Write-Verbose "Can I follow : $_"
                
                    $HREF = $_
                    $Root = $Null

                    if ( -not ( $_ -match 'http:\/\/' ) ) { 
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

                                if ( -Not (Test-IEWebPath -Url $Root$HREF) ) {
                                    Throw "Get-PImage : WebPage does not exist $Root$HREF"
                                } 
                            }



                            Write-Verbose "Get-PImages : ---------------------------- Following Link: $Root$HREF"
                            Try {
                                    # ----- Check if we are recursing and how deep we have gone.
                                    if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                        Write-Output ( Get-IEWebPage -Url $Root$HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose )
                                    }
                                }
                                Catch {
                                    # ----- If error following web link.  Try getting web root and following that
                                    $Root = Get-HTMLRootUrl -Url $WP.Url -Verbose 
                                    Write-Verbose "Error -- Will Try : $Root$HREF "
                                    # ----- Check if we are recursing and how deep we have gone.
                                    if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                        Write-Output ( Get-IEWebPage -Url $Root$HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose )
                                    }

                            }
                        }
                        else {

                            Write-Verbose "Get-PImages : -------------------- Following Link: $HREF"


                            # Write-Output (Get-IEWebPage -url $HREF -Visible | Get-Pics -Verbose)
                            # ----- Check if we are recursing and how deep we have gone.
                            if ( $RecurseLevel -le $MaxRecurseLevel+1 ) { 
                                Write-Output (Get-IEWebPage -url $HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose)
                            }
                    }
                }
            }
  
            if ( $WP.HTML.Links | where href -like  *.html ) { Break }

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
                        $Pics = Get-IEWebPage -url $HREF -Visible | Get-PImages -RecurseLevel $RecurseLevel -Verbose
                    }

                    Write-Output $Pics
                }
                
            }

            if ( $Pics ) { Break }
           
        }
    }



}

#--------------------------------------------------------------------------------------

