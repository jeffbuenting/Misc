$Beer = Import-CSV 'C:\temp\2015 - Best Beer in Every State.txt'

$Beer | Foreach { 
    $_.State = ($_.State -creplace '([A-Z]{1,2})',' $1').trim()
    $_.Beer = ($_.Beer -creplace '([A-Z]{1,2})',' $1').trim()
    $_.Brewery = ($_.Brewery -creplace '([A-Z]{1,2})',' $1').trim()
    $_.BeerStyle = ($_.BeerStyle -creplace '([A-Z]{1,2})',' $1').trim()
    $_.awards = ($_.Awards -creplace '([A-Z]{1,2})',' $1').trim()
}

$Beer | export-csv "c:\temp\2015 - Best beer in every state.csv"