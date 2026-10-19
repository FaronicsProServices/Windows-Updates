#Requires -RunAsAdministrator
<#
.SYNOPSIS
    KB5127648 workaround, single purpose: sets BlockNtlmv1SSO = 0 (Audit). No variables.
.DESCRIPTION
    Fleet-wide version of Set-BlockNtlmv1SSOAudit.ps1 with no DryRun/Rollback switches,
    so it cannot be mis-set to Enforce. Keeps PCC ACCESS (GPO TEAP profile) and wired
    802.1X (GPO TEAP profile) working on devices patched with KB5127648, whose default
    is Enforce. Harmless on unpatched devices (0 is the pre-update default) and holds
    through the update once set. Takes effect without a reboot (verified 2026-10-15).
    Approved by Security (emergency change). Verify with sensor win_os_build_ubr
    (ntlmv1sso=0).

Value: HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0  BlockNtlmv1SSO  REG_DWORD 0
Execution Context: System    Architecture: 64-bit    Timeout: 2 min
Output: one line. Exit 0 = set/already set, 1 = error.

PCC Endpoint - J. White, 2026-10-15
#>
$Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0'
$Name = 'BlockNtlmv1SSO'
try {
    $cv  = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    $cur = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    $was = if ($null -eq $cur) { 'not set' } else { "$cur" }
    if ($cur -eq 0) { "build $($cv.CurrentBuild).$($cv.UBR) | $Name already 0"; exit 0 }
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value 0 -Force | Out-Null
    $after = (Get-ItemProperty -Path $Path -Name $Name).$Name
    if ($after -ne 0) { "build $($cv.CurrentBuild).$($cv.UBR) | FAILED, $Name is $after"; exit 1 }
    "build $($cv.CurrentBuild).$($cv.UBR) | $Name was $was, set to 0"
    exit 0
}
catch {
    $m = $_.Exception.Message; if ($m.Length -gt 80) { $m = $m.Substring(0,80) }
    "error | $m"; exit 1
}
