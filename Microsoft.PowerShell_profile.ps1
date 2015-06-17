Function Invoke-Environment
(
    [Parameter(Mandatory=$true)] [string]
    # Any cmd shell command, normally a configuration batch file.
    $Command
)
{
  cmd /c """$Command"" > nul 2>&1 && set" | .{process{
      if ($_ -match '^([^=]+)=(.*)') {
          [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
      }
  }}
  if ($LASTEXITCODE) {
      throw "Command '$Command': exit code: $LASTEXITCODE"
  }
}
function Open-Solution
{
  $solution = gci *.sln | Select-Object -First 1
  devenv $solution
}
function Goto-TestExecution
{
  Push-Location C:\Depot\Infrastructure\source\Core\
}
function Goto-Private
{
  Push-Location C:\repos\private\
}
function Goto-Powershell
{
  Push-Location $PROFILE\..
}

Write-host "Starting PowerShell Profile for " -NoNewLine
Write-host "$env:USERNAME" -ForegroundColor Green

Write-host "Configuring Paths and Aliases..." -NoNewLine -ForegroundColor Yellow

New-Alias msdev Open-Solution
New-Alias  -name SourceTree "C:\Program Files (x86)\Atlassian\SourceTree\SourceTree.exe" -Scope "global"

$Env:Path+=";$Env:ProgramData\chocolatey\lib\sysinternals\tools\"

Write-host "Done!" -ForegroundColor Green

Write-host "Starting VS CMD Environment..." -NoNewLine -ForegroundColor Yellow
Invoke-Environment (join-path $env:VS120COMNTOOLS "vsvars32.bat")
Write-host "Done!" -ForegroundColor Green

Write-host "Starting posh-git..." -NoNewLine -ForegroundColor Yellow
# Load posh-git example profile
if(Test-Path Function:\Prompt) {Rename-Item Function:\Prompt PrePoshGitPrompt -Force}
. 'C:\tools\poshgit\dahlbyk-posh-git-7acc70b\profile.example.ps1'
Rename-Item Function:\Prompt PoshGitPrompt -Force
function Prompt() {if(Test-Path Function:\PrePoshGitPrompt){++$global:poshScope; New-Item function:\script:Write-host -value "param([object] `$object, `$backgroundColor, `$foregroundColor, [switch] `$nonewline) " -Force | Out-Null;$private:p = PrePoshGitPrompt; if(--$global:poshScope -eq 0) {Remove-Item function:\Write-Host -Force}}PoshGitPrompt}
Write-host "Done!" -ForegroundColor Green
cd $env:USERPROFILE
