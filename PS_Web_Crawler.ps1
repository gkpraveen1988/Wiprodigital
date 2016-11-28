# Purpose of the scripts
# Web crawling to the URL and finding the static contents and URL's visited

$temp_location = (Get-ChildItem env:TEMP).value    # Assiging the temp location
$webreq = Invoke-WebRequest -UseBasicParsing http://wiprodigital.com 
$webreq.Content |Out-File $temp_location\output.txt # Getting the page source and putting to a file

# Looping the contents of the file to find the http values
foreach ($i in (Get-Content $temp_location\output.txt)) 
{
$process_output_file =  [regex]::match($i,'http://[^>]+"\s').Groups[0].value
$process_output_file  |Out-File $temp_location\out1.txt -Append
}

# Removing all the unwanted tags and appending to another file
gc $temp_location\out1.txt | where {$_ -ne "" -replace 'target="_self"',''} |select -Unique | Out-File $temp_location\out2.txt
Remove-Item $temp_location\out1.txt


# Removing HREF tag name and removing still unwanted to characters
$out_content = (gc -path $temp_location\out2.txt).Split(' ')
($out_content -match 'http://' -replace 'href=','' -replace '"','').replace("')",'') | Out-File $temp_location\out3.txt

# Defining 2 empty list for storing the URLs and static contents
$URLItems = New-Object System.Collections.Generic.List[System.Object]
$staticitems = New-Object System.Collections.Generic.List[System.Object]

# Seggreating for static contents and URL's 
foreach ($item in (gc -path $temp_location\out3.txt))
{
    if ($item -match '.jpg' -or $item -match '.png' -or $item -match '.gif' -or $item -match '.xml') { $staticitems.add($item) }
    else {
     if ($item -match 'wiprodigital') { $URLItems.Add($item) }
     }
}

foreach ($js_cont in (Get-Content $temp_location\output.txt | where {$_ -match '.js' -and $_ -match 'javascript' }))
{
$out_js =  [regex]::match($js_cont,'src=[^>]+">').Groups[0].value
$js_load = $out_js -replace 'src=','' -replace '"','' -replace '>',''
$staticitems.add($js_load)
}


# Printing the output on the screen
Write-Host "URL's intact with the Current url `n `n"
echo $URLItems
Write-Host "`n`n`n"
Write-Host "Static content from that page `n `n"
echo $staticitems


