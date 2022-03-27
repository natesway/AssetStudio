#!/usr/bin/env pwsh
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [string]
    $SourcePath,
    [Parameter(Mandatory)]
    [string]
    $BuildPath,
    [Parameter()]
    [string]
    $Arch,
    [Parameter()]
    [ArgumentCompleter({@('Debug', 'Release')})]
    [string]
    $BuildType = 'Release',
    
    [Parameter(ValueFromRemainingArguments)]
    [string[]]
    $RemainingArguments
)

$script:ErrorActionPreferexnce = 'Stop'
$script:PSNativeCommandUseErrorActionPreference = $true

$SourcePath = (New-Item -ItemType Directory -Path $SourcePath -Force).FullName
$BuildPath = (New-Item -ItemType Directory -Path $BuildPath -Force).FullName

$confArgs = @()
$confArgs += '-B' + $BuildPath
$confArgs += '-DCMAKE_BUILD_TYPE=' + $BuildType

if ($arch) {
    if ($IsWindows) {
        switch ($arch) {
            'x86' {
                $confArgs += '-A', 'Win32'
            }
            default {
                $confArgs += '-A', $arch
            }
        }
    }
    elseif ($IsMacOS) {
        switch ($arch) {
            'x64' {
                $confArgs += '-D', 'CMAKE_OSX_ARCHITECTURES="x86_64"'
            }
            'arm64' {
                $confArgs += '-D', 'CMAKE_OSX_ARCHITECTURES="arm64"'
            }
            'universal' {
                $confArgs += '-D', 'CMAKE_OSX_ARCHITECTURES="x86_64;arm64"'
            }
            default {
                throw "Unsupported architecture: $arch"
            }
        }
    }
    else {
        switch ($arch) {
            'x86' {
                $confArgs += '-D', 'MXX=32'
                $confArgs += '-DCMAKE_CXX_FLAGS=-m32', '-DCMAKE_C_FLAGS=-m32'
            }
            'x64' {}
            default {
                throw "Unsupported architecture: $arch"
            }
        }
    }
}

$confArgs += $sourcePath     
$confArgs += $RemainingArguments

Write-Output "Configure with args: $confArgs"
if($PSCmdlet.ShouldProcess('cmake', $confArgs)) {
    cmake @confArgs
}

$buildArgs = @()
$buildArgs += '--build', $BuildPath
$buildArgs += '--config', $BuildType

Write-Output "Build with args: $buildArgs"
if($PSCmdlet.ShouldProcess('cmake', $buildArgs)) {
    cmake @buildArgs
}
