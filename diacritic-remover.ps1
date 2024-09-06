param([string]$target, [boolean]$verbose)

if ($target -eq "") {
    Write-Host "    Specify a folder with -target option"
    Write-Host ""
    Write-Host "        -target 'C:\path\to\folder'"
    Write-Host ""
    exit
}

if (!(Test-Path $target)) {
    Write-Host "    Invalid target"
    Write-Host ""
    Write-Host "        -target $target"
    Write-Host ""
    exit
}

$fileCount = Get-ChildItem -Path $target -File -Recurse | Measure-Object | Select-Object -ExpandProperty Count
Write-Host "This operation will rename any file inside $target (recursively) that contains diacritics in its name, removing them. The number of files that potentially will be renamed is $fileCount."
$response = Read-Host "Are you sure you want to continue? y/n"

if ($response -ine "y") {
    exit
}

Get-ChildItem $target -Recurse -File | Foreach-Object -Begin { $counter, $renamed = 0 } -Process {
    $counter++
    $path = $_.FullName.Substring(0, $_.FullName.LastIndexOf("\") + 1)
    $original = $_.Name
    $normalized = $original.Normalize("FormD")
    $newName = New-Object -TypeName System.Text.StringBuilder
    
    $normalized.ToCharArray() | ForEach-Object -Process {
        if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($psitem) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$newName.Append($psitem)
        }
    }
    
    $newName = ($newName -as [string])
    
    if ($newName -eq $original) {
        if ($verbose) {
            Write-Host "$($counter): No diacritic found on '$original' at $path"
        }
        return
    }
    
    if ($verbose) {
        Write-Host "$($counter): Renaming '$original' to '$newName' at $path"
    }

    try {
        Rename-Item -Path $_.FullName -NewName $newName
        $renamed++
    } catch {
        Write-Host "Could not rename '$original' to '$newName' at $path"
        Write-Error "$_"
    }
}

Write-Host "$renamed files renamed"
