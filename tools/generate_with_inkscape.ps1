$sizes = @(1024,512,384,192,144,96,72,48,36)
New-Item -ItemType Directory -Force -Path assets\icons\generated | Out-Null
$ink = 'C:\Program Files\Inkscape\bin\inkscape.exe'
foreach ($s in $sizes) {
  $out = "assets/icons/generated/app_icon_${s}.png"
  & "$ink" -o $out -w $s -h $s assets/icons/app_icon.svg
  Write-Output "Wrote: $out ($s x $s)"
}
Get-ChildItem assets\icons\generated | Select-Object Name, Length | Format-Table -AutoSize
