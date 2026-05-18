$gamesListUrl = "https://steamrip.com/games-list-page/"
$baseUrl = "https://steamrip.com"

$host.UI.RawUI.WindowTitle = "SteamRIP Download Link Checker"

Write-Host "SteamRIP Direct Download Link Checker" -ForegroundColor Cyan
Write-Host "Type a game name to search or type 'exit' to quit" -ForegroundColor Gray
Write-Host "--------------------------------------------------" -ForegroundColor Gray

function Get-DownloadLinks {
    param([string]$pageUrl)
    
    $downloadLinks = @{
        Gofile = $null
        Buzzheavier = $null
        FileDitch = $null
        OneFichier = $null
        Vikingfile = $null
        MegaDB = $null
    }
    
    try {
        Start-Sleep -Milliseconds 500
        
        $pageContent = (Invoke-WebRequest -Uri $pageUrl -UseBasicParsing -TimeoutSec 10).Content
        
        $gofilePattern = '(?:https?:)?\/\/(?:www\.)?gofile\.(?:io|me|to)\/d\/[a-zA-Z0-9]{5,}'
        $gofileMatch = [regex]::Match($pageContent, $gofilePattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($gofileMatch.Success) {
            $downloadLinks.Gofile = $gofileMatch.Value
            if ($downloadLinks.Gofile -notmatch '^https?://') {
                $downloadLinks.Gofile = "https:" + $downloadLinks.Gofile
            }
        }
        
        $filecryptPattern = '(?:https?:)?\/\/(?:www\.)?filecrypt\.cc\/Container\/[a-zA-Z0-9]+'
        $filecryptMatch = [regex]::Match($pageContent, $filecryptPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($filecryptMatch.Success -and -not $downloadLinks.Gofile) {
            $downloadLinks.Gofile = $filecryptMatch.Value
            if ($downloadLinks.Gofile -notmatch '^https?://') {
                $downloadLinks.Gofile = "https:" + $downloadLinks.Gofile
            }
        }
        
        $buzzheavierPattern = '(?:https?:)?\/\/(?:www\.)?bzzhr\.to\/[a-zA-Z0-9]+'
        $buzzheavierMatch = [regex]::Match($pageContent, $buzzheavierPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($buzzheavierMatch.Success) {
            $downloadLinks.Buzzheavier = $buzzheavierMatch.Value
            if ($downloadLinks.Buzzheavier -notmatch '^https?://') {
                $downloadLinks.Buzzheavier = "https:" + $downloadLinks.Buzzheavier
            }
        }
        
        $fileditchPattern = '(?:https?:)?\/\/(?:www\.)?fileditchfiles\.me\/file\.php\?f=[^\s"\''<>]+'
        $fileditchMatch = [regex]::Match($pageContent, $fileditchPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($fileditchMatch.Success) {
            $downloadLinks.FileDitch = $fileditchMatch.Value
            if ($downloadLinks.FileDitch -notmatch '^https?://') {
                $downloadLinks.FileDitch = "https:" + $downloadLinks.FileDitch
            }
        }
        
        $onefichierPattern = '(?:https?:)?\/\/(?:www\.)?1fichier\.com\/\?[a-zA-Z0-9]+'
        $onefichierMatch = [regex]::Match($pageContent, $onefichierPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($onefichierMatch.Success) {
            $downloadLinks.OneFichier = $onefichierMatch.Value
            if ($downloadLinks.OneFichier -notmatch '^https?://') {
                $downloadLinks.OneFichier = "https:" + $downloadLinks.OneFichier
            }
        }
        
        $vikingfilePattern = '(?:https?:)?\/\/(?:www\.)?vikingfile\.com\/f\/[a-zA-Z0-9]+'
        $vikingfileMatch = [regex]::Match($pageContent, $vikingfilePattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($vikingfileMatch.Success) {
            $downloadLinks.Vikingfile = $vikingfileMatch.Value
            if ($downloadLinks.Vikingfile -notmatch '^https?://') {
                $downloadLinks.Vikingfile = "https:" + $downloadLinks.Vikingfile
            }
        }
        
        $megadbPattern = '(?:https?:)?\/\/(?:www\.)?megadb\.net\/[a-zA-Z0-9]+'
        $megadbMatch = [regex]::Match($pageContent, $megadbPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($megadbMatch.Success) {
            $downloadLinks.MegaDB = $megadbMatch.Value
            if ($downloadLinks.MegaDB -notmatch '^https?://') {
                $downloadLinks.MegaDB = "https:" + $downloadLinks.MegaDB
            }
        }
        
        $buttonPattern = '<a[^>]+href="([^"]+)"[^>]*class="[^"]*shortc-button[^"]*"'
        $buttonMatches = [regex]::Matches($pageContent, $buttonPattern)
        
        foreach ($buttonMatch in $buttonMatches) {
            $href = $buttonMatch.Groups[1].Value
            if ($href -match 'gofile\.(?:io|me|to)\/d\/[a-zA-Z0-9]{5,}' -and -not $downloadLinks.Gofile) {
                $downloadLinks.Gofile = $href
                if ($downloadLinks.Gofile -notmatch '^https?://') {
                    $downloadLinks.Gofile = "https:" + $downloadLinks.Gofile
                }
            }
            elseif ($href -match 'filecrypt' -and -not $downloadLinks.Gofile) {
                $downloadLinks.Gofile = $href
                if ($downloadLinks.Gofile -notmatch '^https?://') {
                    $downloadLinks.Gofile = "https:" + $downloadLinks.Gofile
                }
            }
            elseif ($href -match 'bzzhr\.to\/[a-zA-Z0-9]+' -and -not $downloadLinks.Buzzheavier) {
                $downloadLinks.Buzzheavier = $href
                if ($downloadLinks.Buzzheavier -notmatch '^https?://') {
                    $downloadLinks.Buzzheavier = "https:" + $downloadLinks.Buzzheavier
                }
            }
            elseif ($href -match 'fileditchfiles\.me\/file\.php\?f=' -and -not $downloadLinks.FileDitch) {
                $downloadLinks.FileDitch = $href
                if ($downloadLinks.FileDitch -notmatch '^https?://') {
                    $downloadLinks.FileDitch = "https:" + $downloadLinks.FileDitch
                }
            }
            elseif ($href -match '1fichier\.com\/\?' -and -not $downloadLinks.OneFichier) {
                $downloadLinks.OneFichier = $href
                if ($downloadLinks.OneFichier -notmatch '^https?://') {
                    $downloadLinks.OneFichier = "https:" + $downloadLinks.OneFichier
                }
            }
            elseif ($href -match 'vikingfile\.com\/f\/[a-zA-Z0-9]+' -and -not $downloadLinks.Vikingfile) {
                $downloadLinks.Vikingfile = $href
                if ($downloadLinks.Vikingfile -notmatch '^https?://') {
                    $downloadLinks.Vikingfile = "https:" + $downloadLinks.Vikingfile
                }
            }
            elseif ($href -match 'megadb\.net\/[a-zA-Z0-9]+' -and -not $downloadLinks.MegaDB) {
                $downloadLinks.MegaDB = $href
                if ($downloadLinks.MegaDB -notmatch '^https?://') {
                    $downloadLinks.MegaDB = "https:" + $downloadLinks.MegaDB
                }
            }
        }
    }
    catch {
        $downloadLinks.Gofile = $null
        $downloadLinks.Buzzheavier = $null
        $downloadLinks.FileDitch = $null
        $downloadLinks.OneFichier = $null
        $downloadLinks.Vikingfile = $null
        $downloadLinks.MegaDB = $null
    }
    
    return $downloadLinks
}

try {
    Write-Host "`nDownloading the latest SteamRIP game list..." -ForegroundColor Cyan
    $htmlContent = (Invoke-WebRequest -Uri $gamesListUrl -UseBasicParsing -TimeoutSec 30).Content

    $gameDictionary = @{}
    $exactShortTitles = @()
    $exceptions = @("wwe", "nba")

    $pattern = '<a[^>]+href="([^"]+)"[^>]*>([^<]+Free Download[^<]*)</a>'
    $allMatches = [regex]::Matches($htmlContent, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    foreach ($match in $allMatches) {
        $linkUrl = $match.Groups[1].Value
        $fullTitle = $match.Groups[2].Value

        $fullTitle = [System.Net.WebUtility]::HtmlDecode($fullTitle)
        $fullTitle = $fullTitle -replace '\u2013', '-'

        $cleanTitle = $fullTitle -replace '\s*Free Download\s*', ''
        
        $cleanTitle = $cleanTitle -replace '\s*\([^)]+\)\s*', ''
        $cleanTitle = $cleanTitle -replace '\s*\[[^\]]+\]\s*', ''
        
        $cleanTitle = $cleanTitle.Trim()

        if ($cleanTitle.Length -ge 1 -and $cleanTitle.Length -le 3) {
            $exactShortTitles += $cleanTitle.ToLower()
        }

        if (-not $linkUrl.StartsWith("http")) {
            $linkUrl = $baseUrl + $linkUrl
        }

        $gameDictionary[$cleanTitle.ToLower()] = @{
            OriginalTitle = $cleanTitle
            Url = $linkUrl
        }
    }

    Write-Host "Ready! Loaded $($gameDictionary.Count) games.`n" -ForegroundColor Green

    while ($true) {
        Write-Host ""
        Write-Host "Enter game name: " -ForegroundColor Gray -NoNewline
        $userInput = Read-Host
        
        if ($userInput -eq "exit") {
            Write-Host "Exiting SteamRIP Game Checker. Goodbye!" -ForegroundColor Yellow
            break
        }

        if ([string]::IsNullOrWhiteSpace($userInput)) {
            continue
        }

        $cleanInput = $userInput.Trim().ToLower()

        if ($cleanInput -eq "nba") {
            $cleanInput = "nba 2k"
        }

        if ($cleanInput.Length -le 3 -and $exceptions -notcontains $userInput.ToLower()) {
            $isExactShortTitle = $false
            foreach ($shortTitle in $exactShortTitles) {
                if ($shortTitle -eq $cleanInput) {
                    $isExactShortTitle = $true
                    break
                }
            }

            if (-not $isExactShortTitle) {
                Write-Host "Search term '$userInput' is too short (1-3 letters)." -ForegroundColor Red
                Write-Host "You can only search with 1-3 letters if it EXACTLY matches a game title." -ForegroundColor Yellow
                Write-Host "Try a longer search term (4+ letters)." -ForegroundColor Gray
                continue
            }
        }

        $foundGames = @()

        foreach ($gameKey in $gameDictionary.Keys) {
            if ($gameKey.Contains($cleanInput)) {
                $foundGames += $gameDictionary[$gameKey]
            }
        }

        if ($foundGames.Count -gt 0) {
            Write-Host "Found $($foundGames.Count) match(es):" -ForegroundColor Green

            foreach ($game in $foundGames) {
                Write-Host " - $($game.OriginalTitle)" -ForegroundColor Yellow
                
                $downloads = Get-DownloadLinks -pageUrl $game.Url
                
                $hasLinks = $false
                
                if ($downloads.Gofile) {
                    Write-Host "   GOFILE: $($downloads.Gofile)" -ForegroundColor Cyan
                    $hasLinks = $true
                }
                
                if ($downloads.Buzzheavier) {
                    Write-Host "   BUZZHEAVIER: $($downloads.Buzzheavier)" -ForegroundColor Magenta
                    $hasLinks = $true
                }
                
                if ($downloads.FileDitch) {
                    Write-Host "   FILEDITCH: $($downloads.FileDitch)" -ForegroundColor Green
                    $hasLinks = $true
                }
                
                if ($downloads.OneFichier) {
                    Write-Host "   1FICHIER: $($downloads.OneFichier)" -ForegroundColor Red
                    $hasLinks = $true
                }
                
                if ($downloads.Vikingfile) {
                    Write-Host "   VIKINGFILE: $($downloads.Vikingfile)" -ForegroundColor Yellow
                    $hasLinks = $true
                }
                
                if ($downloads.MegaDB) {
                    Write-Host "   MEGADB: $($downloads.MegaDB)" -ForegroundColor Blue
                    $hasLinks = $true
                }
                
                if (-not $hasLinks) {
                    Write-Host "   No download links found" -ForegroundColor DarkGray
                }
            }
            Write-Host ""
        } else {
            Write-Host "No matches found for: $userInput" -ForegroundColor Red
            Write-Host "Try different spelling or check the full list at: $gamesListUrl" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "`nERROR: Failed to retrieve data. Check internet connection." -ForegroundColor Red
}