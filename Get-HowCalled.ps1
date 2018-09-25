# ----- http://tommymaynard.com/ql-determine-if-the-alias-or-function-name-was-used/

Function Get-TMHowCalled {

    param (
        [String]$Hello
    )
    $Myinvocation
    write-output "*$($MyInvocation.line)*"
    If ($MyInvocation.invocationName -eq 'ghc') {
        Write-Output -Verbose 'Alias was used.'
    } ElseIf ($MyInvocation.InvocationName -eq 'Get-TMHowCalled') {
        Write-Output -Verbose 'Function name was used.'
    }
}

New-Alias -Name ghc -Value Get-TMHowCalled 

Get-TMHowCalled -Hello "What"

ghc -Hello There
