# diacritic-remover

PowerShell script to rename files with diacritics in their names.

## Be cautious

The script will scan all files recursively inside the target.

## How to use

Just run:
```
.\diacritic-remover.ps1 -target path/to/folder
```

Optionaly you can pass an option to show verbose logs:
```
.\diacritic-remover.ps1 -target path/to/folder -verbose 1
```
