﻿#--------------------------------------------------------------------------------------------
# Impersonation.psm1  module
#
# Allows impersonation for powershell cmdlets that do not support alternate credentials like copy-item
# Copy to your Documents\windowspoershell\modudules\impersonation\impersonation.psm1 and use IMPORT-MODULE Impersonation to load it
#
# Example:
#
#$cred = Get-Credential
# Push-ImpersonationContext $cred
# Copy-Item \Server\Share\Folder\*.log C:\Logs
# Pop-ImpersonationContext
#
# http://huddledmasses.org/using-alternate-credentials-with-the-filesystem-in-powershell/
#--------------------------------------------------------------------------------------------

$global:ImpContextStack = new-object System.Collections.Generic.Stack[System.Security.Principal.WindowsImpersonationContext]
$global:IdStack = new-object System.Collections.Generic.Stack[System.Security.Principal.WindowsIdentity]


$global:UserToysClass = Add-Type -Namespace Huddled -Name UserToys -MemberDefinition @"
   // http://msdn.microsoft.com/en-us/library/aa378184.aspx
   [DllImport("advapi32.dll", SetLastError = true)]
   public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);

   // http://msdn.microsoft.com/en-us/library/aa379317.aspx
   [DllImport("advapi32.dll", SetLastError=true)]
   public static extern bool RevertToSelf();
"@ -passthru


function Push-ImpersonationContext {
[CmdletBinding(DefaultParameterSetName="Credential")]
Param(
[Parameter(Position=0,Mandatory=$true,ParameterSetName="Credential")]
[System.Management.Automation.PSCredential]$Credential, 
[Parameter(Position=0,Mandatory=$true,ParameterSetName="Password")]
[string]$name,
[Parameter(Position=1,Mandatory=$true,ParameterSetName="Password")]
$password = (Read-Host "Password" -AsSecureString),
[Parameter(Position=2,Mandatory=$false,ParameterSetName="Password")]
[string]$domain
)
if(!$Credential) {
   if($password -is [string]) {
      $secure = New-Object System.Security.SecureString
      $password.GetEnumerator() | %{ $secure.AppendChar( $_ ) }
      $password = $secure
   }
   if($domain) {
      $user = "${name}@${domain}"
   }
   $Credential = new-object System.Management.Automation.PSCredential $user, $password
}

   Write-Verbose ([Security.Principal.WindowsIdentity]::GetCurrent() | Format-Table Name, Token, User, Groups -Auto | Out-String)

   [IntPtr]$userToken = [Security.Principal.WindowsIdentity]::GetCurrent().Token
   if(!$UserToysClass::LogonUser( 
         $Credential.GetNetworkCredential().UserName, 
         $Credential.GetNetworkCredential().Domain, 
         $Credential.GetNetworkCredential().Password, 9, 0, [ref]$userToken)
   ) {
      throw (new-object System.ComponentModel.Win32Exception( [System.Runtime.InteropServices.Marshal]::GetLastWin32Error() ) )
   }

   $identity = New-Object Security.Principal.WindowsIdentity $userToken
   $global:IdStack.Push( $identity )
   
   $context = $Identity.Impersonate()
   $global:ImpContextStack.Push( $context )

   Write-Verbose ([Security.Principal.WindowsIdentity]::GetCurrent() | Format-Table Name, Token, User, Groups -Auto | Out-String)
   
   return $global:ImpContextStack.Peek()
}


function Pop-ImpersonationContext {
   $context = $global:ImpContextStack.Pop()
   $context.Undo();
   $context.Dispose();
}

function Get-ImpersonationContext {
   Write-Host "There are $($global:ImpContextStack.Count) contexts on the stack"
   $global:ImpContextStack.Peek()
}