Function Get-PImages {

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [PSCustomObject[]]$WebPage,

        [string[]]$ExcludedWords,

        [int]$RecurseLevel = 0,

        [int]$MaxRecurseLevel = 1
    ) 

    process {
        Write-Verbose "Get-PImage : Recurse Level : $RecurseLevel"
        Write-Verbose "Adding recurse level"
        $RecurseLevel ++

        ForEach ( $WP in $WebPage ) {

            Write-Verbose "Get-PImages : Getting Images from $($WP.URL)..."

            Try {
                Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
                Write-Verbose " Get-PImageJPGFromSRC"
                Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"      

                $Pics = Get-PImageJPGFromSRC -WebPage $WP -ExcludedWords $ExcludedWords -Verbose -ErrorAction Stop 
             
                if ( $Pics ) { 
                    Write-Verbose "images from src"
                    Write-Verbose "$($Pics | out-string)"
                    Write-Output $Pics
                    break 
                }
            }
            Catch {
                $ExceptionMessage = $_.Exception.Message
                $ExceptionType = $_.Exception.GetType().FullName
                Throw "Get-PImage : Error getting images from SRC.`n`n     $ExceptionMessage`n     $ExceptionType"
            }

            
            # ----- Check for full URL to Images ( jpgs )
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Write-Verbose " Get-PImageJPGFromFullUr"
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Try {
                $Pics =  Get-PImageJPGFFromFullURL -WebPage $WP -ExcludedWords $ExcludedWords -Verbose -ErrorAction Stop

                if ( $Pics ) { 
                    Write-Verbose "full URL to Images ( jpgs )"
                    Write-Verbose "$($Pics | out-string)"
                    Write-Output $Pics
                    break 
                }
            }
            Catch {
                $ExceptionMessage = $_.Exception.Message
                $ExceptionType = $_.Exception.GetType().FullName
                Throw "Get-PImage : Error full URL to Images ( jpgs ).`n`n     $ExceptionMessage`n     $ExceptionType"
            }
            
            # ----- Check to see if there are links to images ( jpgs ) - Relative Links (not full URL)
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Write-Verbose " Get-PImageJPGFromRelativeLink"
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Try {
                $Pics = Get-PImageJPGFFromRelativeLink -WebPage $WP -ExcludedWords $ExcludedWords -Verbose -ErrorAction Stop
            
                if ( $Pics ) { 
                    Write-Verbose "JPGs from Relative Links"
                    Write-Verbose "$($Pics | out-string)"
                    Write-Output $Pics
                    break 
                }

                Write-Verbose "!!!!!!! No JPG from Relative Links"
            }
            Catch {
                $ExceptionMessage = $_.Exception.Message
                $ExceptionType = $_.Exception.GetType().FullName
                Throw "Get-PImage : Error JPGs from Relative Links.`n`n     $ExceptionMessage`n     $ExceptionType"
            }

            

            # ----- Check for links to image page ( ddd.htm )
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Write-Verbose " Get-PImageJPGFromHTMLLink"
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Try {
                $Pics = Get-PImageJPGFFromHTMLLink -WebPage $WP -ExcludedWords $ExcludedWords -Verbose -ErrorAction Stop
  
                if ( $Pics ) { 
                    Write-Verbose "JPGs links to images"
                    Write-Verbose "$($Pics | out-string)"
                    Write-Output $Pics
                    break 
                }
            }
            Catch {
                $ExceptionMessage = $_.Exception.Message
                $ExceptionType = $_.Exception.GetType().FullName
                Throw "Get-PImage : Error JPGs links to images.`n`n     $ExceptionMessage`n     $ExceptionType"
            }

            # ----- Checking for links where the src is a jpg thumbnail ( link does not end in html )
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Write-Verbose " Get-PImageJPGFromThumbnailSRC"
            Write-Verbose "Get-PImages : -------------------------------------------------------------------------------------"
            Try {
                $Pics = Get-PImageJPGFFromThumbnailSRC -WebPage $WP -ExcludedWords $ExcludedWords -Verbose -ErrorAction Stop

                if ( $Pics ) { 
                    Write-Verbose "Checking for links where the src is a jpg thumbnail ( link does not end in html )"
                    Write-Verbose "$($Pics | out-string)"
                    Write-Output $Pics
                    break 
                }
           }
            Catch {
                $ExceptionMessage = $_.Exception.Message
                $ExceptionType = $_.Exception.GetType().FullName
                Throw "Get-PImage : Error Checking for links where the src is a jpg thumbnail.`n`n     $ExceptionMessage`n     $ExceptionType"
            }
        }
    }



}