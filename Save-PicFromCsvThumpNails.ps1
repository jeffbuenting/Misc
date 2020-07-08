
try {
        import-module C:\Scripts\InternetExplorer\InternetExplorer.psd1 -force -ErrorAction Stop

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

$Listfile = 'P:\links\savepics.csv'
$Num = 15


$Path = 'P:\Links\2010\2010 jun'

import-module C:\scripts\Shortcut\shortuct.psd1

# ----- Getting links from folder
 #   $Links = @()
 #   Get-ChildItem -Path $Path -File | sort-object name  | Select-object -first 2 | Resolve-ShortcutFile | foreach {
 #       $L = New-Object -TypeName PSObject -Property (@{
 #           Url = $_.Url
 #           Path = $Null
 #           ShortcutPath = $_.FIleName
 #       })
 #   
 #       $Links += $L
 #   }


# ----- Getting Links from File
   $Links = import-csv -Path $Listfile 

$ResaveLinks = $Links



 # ----- List of words to ignore if they are part of an image link
$ExcludedWords = '-set.jpg',
            '000000001','0003.jpg','0c2\d*','0c37\d\.jpg','01_0\d',
            '11747',
            '2\d*-\d*-.{6}\.jpg','22962675.jpg',
            '300nn2','31504128.jpg','31273357.jpg','33-189-.*\.jpg','346.jpg','392x72_4','5009.jpg','/17_','/7_','468x60','468x100d.jpg','45fl.jpg',
            '468x80_art-lingerie_2.jpg',
            '5002.jpg',
            '60_001.jpg','6823710','6960553.jpg','6833789.jpg','6833789.jpg','6732258.jpg',
            '7112430','7113434','7060344.jpg','7083247.jpg','7113434','400.jpg','728_4.jpg',
            '80-7.jpg',
            '96x96','98.jpg',
            'a\d\d\d','aa-ban','abbey','addamsyes.jpg','action','ajinx.jpg','akiss.jpg','alirose','alisonbraz.jpg','alisa-kiss.jpg','alexsisf','alley\d+','ally1.jpg','amstuff','anselee2','anissamature','angelabraz','and01','annarose','ariac','arielnude','atk','allstarban.jpg','lstar.jpg','ahmc.jpg','ann5.jpg','antonella.jpg','avatar.jpg','avery','ashlee.jpg','ava\d',
            '/b/','babess','babevr','backtohome','backtohome','badoinkvr\d*','baebz.jpg','baesnaps.jpg','baileyknox','banner','bella.jpg','Bella-Loves-To-Talk-Dirty','bellaclu','big.jpg','big-img','bignatban','bigpic','bikinigirls.jpg','bls_300x167.jpg','bmarie.jpg','bn.jpg','bonus.jpg','bustylegends','bustypl_maria01','bookmark','box_title_main_menu','brianaya','brid','brook.*','bulkpic','bianca1.jpg',
            ,'babesbnr','baberoad.jpg','bann-01b.jpg','bray',
            'candicefoxes','castingcouch','catycole','chaturbate_busty','CheekyA','chelsea','chloevevrier','cjmiles','/cm/','csh_468x80_2.jpg','chase.jpg','chaturbate_big_boobs','charlotte','cherrypimps','cosmid.jpg','cropped-stockings','cake.jpg','candygirl.jpg','chey.jpg','camsodagirl.jpg','closelabel','collegegf','cover','cwhyes','CXiXwn.jpg',
            'danidan.jpg','danica.jpg','danielle3','dannigee','darciebraz.jpg','darciecher.jpg','nymoody.jpg','ddfyes.jpg','dannii.jpg','diana\d+','dice.jpg','dirtytalkinglowres','dream','digitaldesire',
            'eyr.jpg','ecole.jpg','eclub.jpg','egasson.jpg','edildo.jpg','elizabraz','ellabraz','emberbanathome','emilybloom','esperanza.jpg','evalovia.*','evilangel.*','ewa',
            'fancentro.jpg','fdau1','fhg_head','fp\d\.jpg','freemovie','friends','front','frontpage','fondo\d+_\d','footer','fowler.jpg','foxxy','ftv.*','freckles.jpg','fsc.jpg','freecams.jpg','folio.jpg','-f2.jpg',
            'gallery-','gallery_','gemma.jpg','gfleaks','girls/?','girlsway.jpg','gfr','gainsize.jpg','glamm.jpg','glamouridols','glamourshow.jpg',
            'haley55','hardcore','harmony','hdr','himg.jpg','hdlove.jpg','header','header2','hor_','hosteds','high.jpg','hahn.jpg','hayleysec.jpg','hayleys.jpg','hugecocks','humphreys\d*.jpg',
            'iblowjob.jpg','icon-otherofficialsites','ldmban','/?index\d?_','imgs/','/img','images/15','inude.jpg','ingerie.jpg','istri?p.*?\.jpg','ivyy',
            'jadek','JCTitle','jeans_cowboyhat','jelena\d+','jelenasexy','jenann.jpg','jay.jpg','jess\d*','jma','join','jordan','juggsjoy','juliann',
            'kalir','karend','Katie.jpg','katrinporto','katyac','kay.jpg','kelly22','kendraban','kiki','giselle','kaylak.jpg','kris','karinew.jpg','khandi.jpg','kimber','kissban.jpg','kiraqueen.jpg','kendrick.jpg',
            'laylabraz','lb3','leannecrownude','lela','lenapaulbag','littlepics','lia.jpg','lily.jpg','link\d','live1.jpg','logo','long','louise.jpg','lflash.jpg','lucyv.jpg','ley.jpg','ldmyes.jpg','laurenp.jpg','lynda',
            'madison\d','mancini.jpg','main','madden.jpg','mac*kenzies*\d*.jpg','maren.jpg','megan-qt_336','mfcleaderboard_1','miban',,'marxs.jpg','mistygban','monicam.jpg','more','morazzia.jpg','morey','m1.nsimg.net','mya10','myboobs.jpg','myfreecams_bigboobs','mywifeashley','mercedez.jpg','more-galleries.jpg','monroe.*\.jpg',
            'natashaya','natashaban.jpg','neesy','netvideogirls','nf32x32','nbc.jpg','newupdates','nextdoornikki_04_30','nfbusty.jpg','ng2.jpg','ngg','nicolette.jpg','nikki3','ninakayy.jpg','nov','ns-','ntyler.jpg','nise.jpg','netis.jpg','nubilesporn1','nubyes','nmag',
            'oct','offer','officefan.jpg','orig_\d*\.jpg','olivia.jpg','onlysilk','ot\d*','otspecial',
            'pam\d+','paris.jpg','patty','passion','paysite.jpg','paysite_icons','pbtv-\d*','petabraz.jpg','petiteteenager.com','pinup.jpg','pinupfiles.jpg','peta.jpg','playboy','premium.jpg','preetiandpriya01','preview_?','prevv','princess',
            'rain.jpg','ran10','ridol.jpg','robyn.jpg','romibrazzers','rta.jpg','realgirls.jpg',
            'sabann_468x80_02','sarah\d*.jpg','sarah-mcdonald\d*.jpg','sascha','samanta','score.*?\.jpg','Screen-Shot','search','seeher.jpg','separator','shemale','simsnew.jpg','simone_fox-238','sinner','site','sheridan.jpg','siri.jpg','skintightglam','skyla','slide','small','smclub.jpg','snude.jpg','sophiedee1.jpg','sophy.jpg','spencerprem','spinchix.jpg','spring.jpg','stasyq.jpg','stmac.jpg','stockingfetish','stormybraz','studio','sdavies.jpg',
            'spunky.jpg','_sarina.jpg','smallimage\d*','smith.jpg','striplvgirls','suze-750233',
            't.jpg','t1-Join-Now-fitmichelle','tanude.jpg','tasha.jpg','teenravepink','tcurve','Template','tgp','t\d*','th_\d+','th\d*x\d*','tk_','tn.*?\.jpg','tn2','tn_','/tn','tn-','tessa.jpg','tasia.jpg','top','totemnewyes3.jpg','tranny.jpg','trueamateur.jpg','typein.jpg','twitter',
            'vanessa-black-lace-one-piece-bella-club-2.jpg','vertical.jpg','victoria','vta','sarinavalentina.jpg','vrcosplayx',
            'w4b','wankr','webcam','webcamyes.jpg','wellhello.jpg','wide[_\-]','wifey.jpg','withher.jpg','ws','ww2.jpg','webbie.jpg',
            'yanks','yea.jpg','ytease.jpg','ycake.jpg','ywinters.jpg','yesboobs.jpg','yjay.jpg',
            'zara4.jpg','zishy.jpg'
 


# ----- Determines if we open explorere to verify if the images saved or not.
$VerboseTest = $True

$ImageSaveIssue = @()
$FileExists = @()

foreach ( $L in $Links ) {
#$Links | Select-object -First $Num | Foreach {
  #  $L = $_

    # ----- Remove obj from list to be saved at end
    $RemoveLink,$ResaveLinks = $ResaveLinks

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

                    Write-Host "Getting existing files"
                    $Existing = Get-Childitem -Path $DestinationPath



             #       Write-Host "Opening Destination to double check if the images already exist" -ForegroundColor Green
             #       explorer $DestinationPath
             #       if ( (New-Popup -Message "Do the images already exist?" -Title 'No errors' -Time 60 -Buttons 'YesNo') -eq 6 ) {
            
              #      }
                    # ----- Save link to write to log
        #            $FileExists += $L
        #            Continue
            }
                    
    }

  
   

    $Images = $Null




    $I = $IE | Get-PImages -verbose -ExcludedWords $ExcludedWords


    Write-Host "Check if image already exists in folder"
    $Images = @()

    if ( $Exists ) {

        $I | foreach {
            if ( (Compare-Object $_.split('/')[-1] $Exists.Name -IncludeEqual | where SideIndicator -ne '==') ) {
                $Images += $_

            }
        }
    }
    else {

        $Images = $I
    }
    
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
            # ----- Open Explorer and verify if images saved correctly.
            Write-Host "Opening Destination to double check if the images saved correctly" -ForegroundColor Green
            explorer $DestinationPath

            $Ans = (New-Popup -Message "Did it Save Correctly" -Title 'No errors' -Time 60 -Buttons 'YesNo')
            Write-host "Answer = $Ans"

            if ( $Ans -eq 6 ) { 

                # ----- Yes
                write-host "All Good" -ForegroundColor Green

                # ----- Remove shortcut if  needed
                if ( $L.SHortcutPath ) {
                    Write-Output "Removking SHortcut"
                    Get-Item -Path $L.ShortcutPath | Remove-Item
                }


            }
        }
  #      else { 
  #          
  #          If ( $Images -eq $Null ) {
  #              write-host "Didn't Save,Will write to log" -ForegroundColor Green
  #              $ImageSaveIssue += $L
  #          }
  #      }
    }
        


    # ----- Clean up
    write-host "Closing web page" -ForegroundColor Green 

    Close-IEWebPage -WebPage $IE -verbose


}

Write-Host "Writing to error logs" -ForegroundColor Green
#$ImageSaveIssue | export-csv p:\links\ImageSaveIssues.csv -NoTypeInformation -Append
#$FileExists | Export-CSV p:\links\FileExists.csv -NoTypeInformation -Append


Write-output "Resaving links "
#$ResaveLinks | export-csv $Listfile -Force -NoTypeInformation

Write-Output "Errors Saving these"
#$imageSaveIssue