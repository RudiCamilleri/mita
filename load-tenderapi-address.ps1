$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
while ($true) {
	$stream = New-Object System.IO.FileStream(".\ganache-output.txt", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
	$reader = New-Object System.IO.StreamReader($stream)
	$content = $reader.ReadToEnd()
	$reader.Dispose()
	$stream.Dispose()
	$search_string = "Contract created: "
	$index = $content.IndexOf($search_string)
	if ($index -eq -1) {
		sleep 1
	} else {
		$index += $search_string.length
		$end = $index
		while (($end -lt $content.length) -and !([String]::IsNullOrWhiteSpace($content.Substring($end, 1)))) {
			$end++
		}
		$address = $content.Substring($index, $end - $index).Trim()
		$js = "var TenderApiAddress='" + $address + "'"
		$js | Out-File ".\init-tenderapi-address.js"
		Break
	}
}