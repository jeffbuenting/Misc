try {
        import-module C:\Scripts\InternetExporer\InternetExplorer.psd1 -force -ErrorAction Stop
        Import-Module C:\scripts\FileSystem\filesystem.psd1 -force -ErrorAction Stop
        Import-Module C:\scripts\Misc\p\p.psd1 -force -ErrorAction Stop
        Import-Module c:\scripts\popup\popup.psm1 -force -ErrorAction Stop
        Import-Module C:\scripts\Shortcut\Shortcut.psm1 -Force -ErrorAction Stop
    }
    Catch {
        $ExceptionMessage = $_.Exception.Message
        $ExceptionType = $_.Exception.GetType().FullName
        Throw "Problem importing modules.`n`n     $ExceptionMessage`n     $ExceptionType"
}

$Links = Import-CSV -Path 'P:\links\savepics.csv'

 # ----- List of words to ignore if they are part of an image link
$ExcludedWords = '\d*x\d*\.jpg','\d\d_\d\d\.jpg',
            '-set.jpg',
            '0003.jpg','0c257637.jpg','0c373112.jpg',
            '22962675.jpg','31504128.jpg','31273357.jpg','346.jpg','5009.jpg','/17_','/7_','468x60','468x100d.jpg','45fl.jpg',
            '468x80_art-lingerie_2.jpg',
            '5002.jpg',
            '60_001.jpg','6823710','6960553.jpg','6833789.jpg','6833789.jpg','6732258.jpg',
            '7112430','7113434','7060344.jpg','7083247.jpg','7113434','400.jpg','728_4.jpg',
            '80-7.jpg',
            '98.jpg',
            'addamsyes.jpg','ajinx.jpg','akiss.jpg','alisonbraz.jpg','ally1.jpg','angelabraz','anna','atk','allstarban.jpg','lstar.jpg','ahmc.jpg','ann5.jpg','antonella.jpg','avatar.jpg','ashlee.jpg',
            '/b/','backtohome','backtohome','badoinkvr1.jpg','baebz.jpg','baesnaps.jpg','banner','bella.jpg','bellaclu','big.jpg','bikinigirls.jpg','bmarie.jpg','bn.jpg','bookmark','box_title_main_menu','brooklynna.jpg','bulkpic','bianca1.jpg',
            'baberoad.jpg','bann-01b.jpg',
            '/cm/','csh_468x80_2.jpg','chase.jpg','cosmid.jpg','cake.jpg','candygirl.jpg','chey.jpg','camsodagirl.jpg','CXiXwn.jpg',
            'darciecher.jpg','nymoody.jpg','ddfyes.jpg','dannii.jpg','dice.jpg','dream',
            'eyr.jpg','ecole.jpg','eclub.jpg','egasson.jpg','edildo.jpg','esperanza.jpg','evilangelmini2','ewa',
            'fancentro.jpg','friends','front','frontpage','footer','fowler.jpg','ftvm.jpg','ftvgirls.jpg','freckles.jpg','fsc.jpg','freecams.jpg','folio.jpg','-f2.jpg',
            'gallery-','gallary_','gemma.jpg','girls/','girlsway.jpg','gainsize.jpg','glamm.jpg','glamourshow.jpg',
            'himg.jpg','hdlove.jpg','header','header2','hor_','high.jpg','hahn.jpg','hayleysec.jpg','hayleys.jpg',
            'iblowjob.jpg','/index_','imgs/','/img','images/15','inude.jpg','ingerie.jpg','istrp.jpg',
            'jelenasexy','jenann.jpg','jay.jpg','jess\d*',
            'Katie.jpg','katrinporto','kay.jpg','kris','karinew.jpg','khandi.jpg','kimber.jpg','kissban.jpg','kiraqueen.jpg','kendrick.jpg',
            'littlepics','lia.jpg','lily.jpg','live1.jpg','logo','louise.jpg','lflash.jpg','lucyv.jpg','ley.jpg','ldmyes.jpg','laurenp.jpg',
            'mancini.jpg','main','madden.jpg','mac*kenzies*\d*.jpg','maren.jpg','marxs.jpg','monicam.jpg','morazzia.jpg','m1.nsimg.net','myboobs.jpg','mercedez.jpg','more-galleries.jpg','monroe.*\.jpg',
            'natashaban.jpg','newupdates','nfbusty.jpg','ng2.jpg','ngg','nicolette.jpg','ninakayy.jpg','nov','ntyler.jpg','nise.jpg','netis.jpg',
            'oct','offer','officefan.jpg','orig_\d*\.jpg','olivia.jpg',
            'paris.jpg','paysite.jpg','paysite_icons','petabraz.jpg','pinup.jpg','pinupfiles.jpg','peta.jpg','premium.jpg',
            'rain.jpg','ridol.jpg','robyn.jpg','rta.jpg','realgirls.jpg',
            'sascha','scorelandyes.jpg','Screen-Shot','search','seeher.jpg','separator','simsnew.jpg','sheridan.jpg','siri.jpg','slide','small','smclub.jpg','snude.jpg','sophiedee1.jpg','sophy.jpg','spinchix.jpg','spring.jpg','stasyq.jpg','stmac.jpg','sdavies.jpg',
            'spunky.jpg','_sarina.jpg','smith.jpg',
            't.jpg','tanude.jpg','Template','tgp','thumb','tk_','tn.*?\.jpg','tn2','tn_','/th','/tn','tn-','tessa.jpg','tasia.jpg','totemnewyes3.jpg','tranny.jpg','trueamateur.jpg','typein.jpg',
            'upload/',
            'vanessa-black-lace-one-piece-bella-club-2.jpg','vertical.jpg','sarinavalentina.jpg',
            'webcam','webcamyes.jpg','wellhello.jpg','wifey.jpg','withher.jpg','ww2.jpg','webbie.jpg',
            'yea.jpg','ytease.jpg','ycake.jpg','ywinters.jpg','yesboobs.jpg','yjay.jpg',
            'zara4.jpg','zishy.jpg'


$VerboseTest = $True

$ImageSaveIssue = @()
$FileExists = @()

foreach ( $L in $Links ) {

    write-host "Link:  $($L.Url)" -ForegroundColor Green
    Write-Host "Path:  $($L.Path)" -ForegroundColor Green

    $IE =  $L.Url | Get-IEWebPage -Visible -verbose

    # ----- Manually get the save path if one is not in the CSV
    if ( -Not ( $L.Path ) ) {
            $DestinationPath = Get-FileorFolderPath -InitialDirectory 'p:\'
            if ( -Not $DestinationPath ) { Continue }
        }
        else {
            $DestinationPath = $L.Path
            If ( -Not (Test-Path $DestinationPath) ) {
                    Write-Host "Creating Directory $DestinationPath" -ForegroundColor Green
                    MD $DestinationPath
                }
                else {
                     
                    Write-Host "Destination already Exists: $destinationPath" -ForegroundColor Yellow
                    Write-Host "Opening Destination to double check if the images already exist" -ForegroundColor Green
                    explorer $DestinationPath
                    if ( (New-Popup -Message "Do the images already exist?" -Title 'No errors' -Time 300 -Buttons 'YesNo') -eq 6 ) {
            
                    }
                    # ----- Save link to write to log
                    $FileExists += $L
                    Continue
            }
                    
    }

  
   

    $Images = $Null




    $Images = $IE | Get-PImages -verbose -ExcludedWords $ExcludedWords
    
    "-----------"   
    $Images
    "-----------" 

    $Images.Count

    if ( $Images.Count -gt 0 ) {

            
        $Link = $IE.Url

        Write-Host "Saving Shortcut"
        New-Shortcut -Link $Link -Path $DestinationPath -Verbose

        Write-Host "Saving images..." -ForegroundColor Green
        $Images | Save-IEWebImage -Destination $DestinationPath -Priority 'ForeGround' -verbose

            
        If ( $VerboseTest ) {
                Write-Host "Opening Destination to double check if the images saved correctly" -ForegroundColor Green
                explorer $DestinationPath

                if ( (New-Popup -Message "Did it Save Correctly" -Title 'No errors' -Time 60 -Buttons 'YesNo') -eq 6 ) {
                    write-host "Didn't Save,Will write to log" -ForegroundColor Green
                    $ImageSaveIssue += $L
                }
            }
            else { 
                If ( $Images -eq $Null ) {
                    write-host "Didn't Save,Will write to log" -ForegroundColor Green
                    $ImageSaveIssue 
                }
        }
    }
        


    # ----- Clean up
    write-host "Closing web page" -ForegroundColor Green 

    Close-IEWebPage -WebPage $IE -verbose


}

Write-Host "Writing to error logs" -ForegroundColor Green
$ImageSaveIssue | export-csv p:\links\ImageSaveIssues.csv -NoTypeInformation -Append
$FileExists | Export-CSV p:\links\FileExists.csv -NoTypeInformation -Append


Remove-Module InternetExplorer