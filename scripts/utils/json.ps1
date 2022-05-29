
function FixJsonIndentation ($jsonOutput)
{
    $currentIndent = 0
    $tabSize = 4
    $lines = $jsonOutput.Split([Environment]::NewLine)
    $newString = ""
    foreach ($line in $lines)
    {
        # skip empty line
        if ($line.Trim() -eq "") {
            continue
        }

        # if the line with ], or }, reduce indent
        if ($line -match "[\]\}]+\,?\s*$") {
            $currentIndent -= 1
        }

        # add the line with the right indent
        if ($newString -eq "") {
            $newString = $line
        } else {
            $spaces = ""
            $matchFirstChar = [regex]::Match($line, '[^\s]+')
            
            $totalSpaces = $currentIndent * $tabSize
            if ($totalSpaces -gt 0) {
                $spaces = " " * $totalSpaces
            }
            
            $newString += [Environment]::NewLine + $spaces + $line.Substring($matchFirstChar.Index)
        }

        # if the line with { or [ increase indent
        if ($line -match "[\[\{]+\s*$") {
            $currentIndent += 1
        }
    }

    return $newString
}