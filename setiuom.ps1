# ============================================================
# setiuom by gabriel
# ============================================================

# configuration
$steamripListUrl = "https://steamrip.com/games-list-page/"
$steamripBaseUrl = "https://steamrip.com"
$steamripTestUrl = "https://steamrip.com/doki-doki-literature-club-plus-free-download-1f/"

$ankerGamesBaseUrl = "https://ankergames.net"

# networking setup
try {
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11
} catch { }

$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
$browserHeaders = @{
    "Accept"          = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
    "Accept-Language" = "en-US,en;q=0.9"
    "Cache-Control"   = "no-cache"
    "Pragma"          = "no-cache"
}

$ProgressPreference = 'SilentlyContinue'
$host.UI.RawUI.WindowTitle = "Setiuom Games Search"

# url fetching
function Get-WebContent {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [int]$TimeoutSec = 30
    )
    $errMsg = $null
    $statusCode = $null
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec $TimeoutSec `
            -UserAgent $userAgent -Headers $browserHeaders -ErrorAction Stop
        return $response.Content
    }
    catch {
        try {
            if ($_.Exception.Response) { $statusCode = [int]$_.Exception.Response.StatusCode }
        } catch { }
        $errMsg = $_.Exception.Message
    }

    $curlAvailable = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curlAvailable -and ($statusCode -in @(403, 429, 503) -or $null -eq $statusCode)) {
        try {
            $curlOut = & curl.exe -s -L --max-time $TimeoutSec --tlsv1.2 --compressed `
                -A $userAgent `
                -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" `
                -H "Accept-Language: en-US,en;q=0.9" `
                $Url 2>$null
            if ($LASTEXITCODE -eq 0 -and $curlOut) {
                return ($curlOut -join "`n")
            }
        } catch { }
    }
    throw "HTTP $statusCode - $errMsg"
}

# title normalization
function Get-NormalizedKey {
    param([string]$title)
    if ([string]::IsNullOrWhiteSpace($title)) { return "" }
    return ($title.ToLower() -replace '[^a-z0-9]+', '')
}

# steamrip availability check
function Test-SteamRIPAvailability {
    $urls = @(
        @{Url = "https://steamrip.com"; Name = "Main Page"},
        @{Url = $steamripListUrl;       Name = "Games List Page"},
        @{Url = $steamripTestUrl;       Name = "Test Game Page"}
    )
    $allPass = $true
    foreach ($item in $urls) {
        try {
            Write-Host "   Checking $($item.Name)... " -NoNewline -ForegroundColor Gray
            $content = Get-WebContent -Url $item.Url -TimeoutSec 15
            if ($content -and $content.Length -gt 500) {
                Write-Host "OK" -ForegroundColor Green
            } else {
                Write-Host "FAILED (empty/blocked)" -ForegroundColor Red
                $allPass = $false
            }
        }
        catch {
            Write-Host "FAILED ($($_.Exception.Message))" -ForegroundColor Red
            $allPass = $false
        }
    }
    return $allPass
}

# download link extraction
function Get-DownloadLinks {
    param([string]$pageUrl)
    $dl = @{
        Gofile = $null; Buzzheavier = $null; FileDitch = $null
        OneFichier = $null; Vikingfile = $null; MegaDB = $null
    }
    $rx = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase

    try {
        Start-Sleep -Milliseconds 500
        $pageContent = Get-WebContent -Url $pageUrl -TimeoutSec 20

        $m = [regex]::Match($pageContent, '(?:https?:)?\/\/(?:www\.)?gofile\.(?:io|me|to)\/d\/[a-zA-Z0-9]{5,}', $rx)
        if ($m.Success) {
            $dl.Gofile = $m.Value
            if ($dl.Gofile -notmatch '^https?://') { $dl.Gofile = "https:" + $dl.Gofile }
        }
        $m = [regex]::Match($pageContent, '(?:https?:)?\/\/(?:www\.)?filecrypt\.cc\/Container\/[a-zA-Z0-9]+', $rx)
        if ($m.Success -and -not $dl.Gofile) {
            $dl.Gofile = $m.Value
            if ($dl.Gofile -notmatch '^https?://') { $dl.Gofile = "https:" + $dl.Gofile }
        }
        $m = [regex]::Match($pageContent, '(?:https?:)?\/\/(?:www\.)?bzzhr\.to\/[a-zA-Z0-9]+', $rx)
        if ($m.Success) {
            $dl.Buzzheavier = $m.Value
            if ($dl.Buzzheavier -notmatch '^https?://') { $dl.Buzzheavier = "https:" + $dl.Buzzheavier }
        }
        $m = [regex]::Match($pageContent, '(?:https?:)?\/\/(?:www\.)?fileditchfiles\.me\/file\.php\?f=[^\s"\''<>]+', $rx)
        if ($m.Success) {
            $dl.FileDitch = $m.Value
            if ($dl.FileDitch -notmatch '^https?://') { $dl.FileDitch = "https:" + $dl.FileDitch }
        }
        $m = [regex]::Match($pageContent, '(?:https?:)?\/\/(?:www\.)?1fichier\.com\/\?[a-zA-Z0-9]+', $rx)
        if ($m.Success) {
            $dl.OneFichier = $m.Value
            if ($dl.OneFichier -notmatch '^https?://') { $dl.OneFichier = "https:" + $dl.OneFichier }
        }
        $m = [regex]::Match($pageContent, '(?:https?:)?\/\/(?:www\.)?vikingfile\.com\/f\/[a-zA-Z0-9]+', $rx)
        if ($m.Success) {
            $dl.Vikingfile = $m.Value
            if ($dl.Vikingfile -notmatch '^https?://') { $dl.Vikingfile = "https:" + $dl.Vikingfile }
        }
        $m = [regex]::Match($pageContent, '(?:https?:)?\/\/(?:www\.)?megadb\.net\/(?:d\/)?[a-zA-Z0-9]+', $rx)
        if ($m.Success) {
            $dl.MegaDB = $m.Value
            if ($dl.MegaDB -notmatch '^https?://') { $dl.MegaDB = "https:" + $dl.MegaDB }
        }

        $buttonMatches = [regex]::Matches($pageContent, '<a[^>]+href="([^"]+)"[^>]*class="[^"]*shortc-button[^"]*"')
        foreach ($bm in $buttonMatches) {
            $href = $bm.Groups[1].Value
            if ($href -match 'gofile\.(?:io|me|to)\/d\/[a-zA-Z0-9]{5,}' -and -not $dl.Gofile) {
                $dl.Gofile = $href; if ($dl.Gofile -notmatch '^https?://') { $dl.Gofile = "https:" + $dl.Gofile }
            }
            elseif ($href -match 'filecrypt' -and -not $dl.Gofile) {
                $dl.Gofile = $href; if ($dl.Gofile -notmatch '^https?://') { $dl.Gofile = "https:" + $dl.Gofile }
            }
            elseif ($href -match 'bzzhr\.to\/[a-zA-Z0-9]+' -and -not $dl.Buzzheavier) {
                $dl.Buzzheavier = $href; if ($dl.Buzzheavier -notmatch '^https?://') { $dl.Buzzheavier = "https:" + $dl.Buzzheavier }
            }
            elseif ($href -match 'fileditchfiles\.me\/file\.php\?f=' -and -not $dl.FileDitch) {
                $dl.FileDitch = $href; if ($dl.FileDitch -notmatch '^https?://') { $dl.FileDitch = "https:" + $dl.FileDitch }
            }
            elseif ($href -match '1fichier\.com\/\?' -and -not $dl.OneFichier) {
                $dl.OneFichier = $href; if ($dl.OneFichier -notmatch '^https?://') { $dl.OneFichier = "https:" + $dl.OneFichier }
            }
            elseif ($href -match 'vikingfile\.com\/f\/[a-zA-Z0-9]+' -and -not $dl.Vikingfile) {
                $dl.Vikingfile = $href; if ($dl.Vikingfile -notmatch '^https?://') { $dl.Vikingfile = "https:" + $dl.Vikingfile }
            }
            elseif ($href -match 'megadb\.net\/(?:d\/)?[a-zA-Z0-9]+' -and -not $dl.MegaDB) {
                $dl.MegaDB = $href; if ($dl.MegaDB -notmatch '^https?://') { $dl.MegaDB = "https:" + $dl.MegaDB }
            }
        }
    }
    catch {
        $dl.Gofile = $null; $dl.Buzzheavier = $null; $dl.FileDitch = $null
        $dl.OneFichier = $null; $dl.Vikingfile = $null; $dl.MegaDB = $null
    }
    return $dl
}

# steamrip loader
function Load-SteamRIPGames {
    Write-Host "`n[SteamRIP] Checking availability..." -ForegroundColor Cyan
    if (-not (Test-SteamRIPAvailability)) {
        Write-Host "[SteamRIP] Down or blocking requests - skipping." -ForegroundColor Yellow
        return $null
    }

    Write-Host "`n[SteamRIP] Downloading game list..." -ForegroundColor Cyan
    try {
        $htmlContent = Get-WebContent -Url $steamripListUrl -TimeoutSec 30
    } catch {
        Write-Host "[SteamRIP] Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }

    $games = @{}
    $pattern = '<a[^>]+href="([^"]+)"[^>]*>([^<]+Free Download[^<]*)</a>'
    $allMatches = [regex]::Matches($htmlContent, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    foreach ($match in $allMatches) {
        $linkUrl   = $match.Groups[1].Value
        $fullTitle = [System.Net.WebUtility]::HtmlDecode($match.Groups[2].Value)
        $fullTitle = $fullTitle -replace '\u2013', '-'
        $cleanTitle = $fullTitle -replace '\s*Free Download\s*', ''
        $cleanTitle = $cleanTitle -replace '\s*\([^)]+\)\s*', ''
        $cleanTitle = $cleanTitle -replace '\s*\[[^\]]+\]\s*', ''
        $cleanTitle = $cleanTitle.Trim()

        if (-not $linkUrl.StartsWith("http")) { $linkUrl = $steamripBaseUrl + $linkUrl }

        $games[$cleanTitle.ToLower()] = @{
            OriginalTitle = $cleanTitle
            Url           = $linkUrl
        }
    }
    Write-Host "[SteamRIP] Loaded $($games.Count) games." -ForegroundColor Green
    return $games
}

# ankergames loader
function Load-AnkerGamesList {
    Write-Host "`n[AnkerGames] Fetching sitemap index..." -ForegroundColor Cyan
    try {
        $indexXml = Get-WebContent -Url "$ankerGamesBaseUrl/sitemap.xml" -TimeoutSec 30
    }
    catch {
        Write-Host "[AnkerGames] Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }

    $subSitemaps = [regex]::Matches($indexXml, '<loc>([^<]+)</loc>') | ForEach-Object { $_.Groups[1].Value }
    Write-Host "  Found $($subSitemaps.Count) sub-sitemaps" -ForegroundColor Gray

    $games = @{}
    $i = 0
    foreach ($subUrl in $subSitemaps) {
        $i++
        $shortName = ($subUrl -split '/')[-1]

        if ($shortName -notmatch '^sitemap_(post|main)') {
            Write-Host ("    [{0}/{1}] Skip {2}" -f $i, $subSitemaps.Count, $shortName) -ForegroundColor DarkGray
            continue
        }

        try {
            Write-Host ("    [{0}/{1}] Fetching {2}..." -f $i, $subSitemaps.Count, $shortName) -ForegroundColor Gray -NoNewline
            $subXml = Get-WebContent -Url $subUrl -TimeoutSec 30

            $matches = [regex]::Matches($subXml, '<loc>https://ankergames\.net/game/([^<]+)</loc>')
            if ($matches.Count -eq 0) {
                Write-Host " (no game URLs)" -ForegroundColor DarkGray
                continue
            }

            foreach ($m in $matches) {
                $slug  = $m.Groups[1].Value.TrimEnd('/')
                $title = (Get-Culture).TextInfo.ToTitleCase(($slug -replace '-', ' '))
                $key   = Get-NormalizedKey $title
                if (-not $games.ContainsKey($key)) {
                    $games[$key] = @{
                        OriginalTitle = $title
                        Url           = "$ankerGamesBaseUrl/game/$slug"
                    }
                }
            }
            Write-Host (" +{0} games (total {1})" -f $matches.Count, $games.Count) -ForegroundColor Green
            Start-Sleep -Milliseconds 300
        }
        catch {
            Write-Host " FAILED ($($_.Exception.Message))" -ForegroundColor Yellow
        }
    }
    return $games
}

# merge lists
function Merge-GameLists {
    param($steamripGames, $ankergamesGames)
    $unified = @{}

    if ($steamripGames) {
        foreach ($entry in $steamripGames.Values) {
            $norm = Get-NormalizedKey $entry.OriginalTitle
            if (-not $unified.ContainsKey($norm)) {
                $unified[$norm] = @{
                    DisplayTitle = $entry.OriginalTitle
                    SteamRIP     = @{ Url = $entry.Url; Title = $entry.OriginalTitle }
                    AnkerGames   = $null
                }
            }
        }
    }

    if ($ankergamesGames) {
        foreach ($entry in $ankergamesGames.Values) {
            $norm = Get-NormalizedKey $entry.OriginalTitle
            if ($unified.ContainsKey($norm)) {
                $unified[$norm].AnkerGames = @{ Url = $entry.Url; Title = $entry.OriginalTitle }
            } else {
                $unified[$norm] = @{
                    DisplayTitle = $entry.OriginalTitle
                    SteamRIP     = $null
                    AnkerGames   = @{ Url = $entry.Url; Title = $entry.OriginalTitle }
                }
            }
        }
    }

    return $unified
}

# banner
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "                Setiuom Game Search               " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# load both sources
$steamripGames = Load-SteamRIPGames
$ankerGames    = Load-AnkerGamesList

if (-not $steamripGames -and -not $ankerGames) {
    Write-Host "`nBoth sources failed to load. Exiting." -ForegroundColor Red
    exit 1
}

$unifiedGames = Merge-GameLists -steamripGames $steamripGames -ankergamesGames $ankerGames

# first-word index so short queries find games whose first word matches
$stopwords = @('a', 'an', 'the', 'of', 'in', 'on', 'at', 'to', 'and', 'or', 'but', 'is', 'it', 'be')
$firstWordLookup = @{}
foreach ($entry in $unifiedGames.Values) {
    $trimmed = $entry.DisplayTitle.Trim()
    if (-not $trimmed) { continue }
    $firstWord = ($trimmed -split '\s+')[0].ToLower() -replace '[^a-z0-9]', ''
    if ($firstWord.Length -lt 2) { continue }
    if ($stopwords -contains $firstWord) { continue }
    if (-not $firstWordLookup.ContainsKey($firstWord)) {
        $firstWordLookup[$firstWord] = @()
    }
    $firstWordLookup[$firstWord] += $entry
}

# stats
$steamCount = if ($steamripGames) { $steamripGames.Count } else { 0 }
$ankerCount = if ($ankerGames)    { $ankerGames.Count }    else { 0 }
$bothCount  = @($unifiedGames.Values | Where-Object { $_.SteamRIP -and $_.AnkerGames }).Count
$steamOnly  = @($unifiedGames.Values | Where-Object { $_.SteamRIP -and -not $_.AnkerGames }).Count
$ankerOnly  = @($unifiedGames.Values | Where-Object { -not $_.SteamRIP -and $_.AnkerGames }).Count

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host " Ready! Combined $($unifiedGames.Count) unique games" -ForegroundColor Green
Write-Host "   $bothCount on both sites" -ForegroundColor Gray
Write-Host "   $steamOnly SteamRIP only" -ForegroundColor Gray
Write-Host "   $ankerOnly AnkerGames only" -ForegroundColor Gray
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Type a game name to search or 'exit' to quit." -ForegroundColor Gray
Write-Host "--------------------------------------------------" -ForegroundColor Gray

# search loop
while ($true) {
    Write-Host ""
    Write-Host "Enter game name: " -ForegroundColor Gray -NoNewline
    $userInput = Read-Host

    if ($userInput.Trim().ToLower() -eq "exit") {
        Write-Host "Goodbye!" -ForegroundColor Yellow
        break
    }
    if ([string]::IsNullOrWhiteSpace($userInput)) { continue }

    $cleanInputRaw = $userInput.Trim().ToLower()
    $cleanInput = Get-NormalizedKey $cleanInputRaw

    $found = @()

    # short queries: exact match or first-word match, otherwise reject
    if ($cleanInput.Length -le 3) {
        $isExact     = $unifiedGames.ContainsKey($cleanInput)
        $isFirstWord = $firstWordLookup.ContainsKey($cleanInput)

        if (-not $isExact -and -not $isFirstWord) {
            Write-Host "Search term '$userInput' is too short (1-3 letters)." -ForegroundColor Red
            Write-Host "It must be a game's first word (NBA, FC, F1...) or EXACTLY match a title." -ForegroundColor Yellow
            continue
        }

        if ($isFirstWord) {
            $found = @($firstWordLookup[$cleanInput])
        } else {
            $found = @($unifiedGames[$cleanInput])
        }

        if ($found.Count -eq 0) {
            Write-Host "No matches found for: $userInput" -ForegroundColor Red
            continue
        }

        Write-Host "`nFound $($found.Count) match(es):" -ForegroundColor Green

        foreach ($g in $found) {
            Write-Host ""
            Write-Host " -- $($g.DisplayTitle)" -ForegroundColor Yellow

            if ($g.SteamRIP) {
                Write-Host "    [SteamRIP]   $($g.SteamRIP.Url)" -ForegroundColor Cyan
                $dl = Get-DownloadLinks -pageUrl $g.SteamRIP.Url
                $has = $false
                if ($dl.Gofile)      { Write-Host "      GOFILE: $($dl.Gofile)"           -ForegroundColor Cyan;    $has = $true }
                if ($dl.Buzzheavier) { Write-Host "      BUZZHEAVIER: $($dl.Buzzheavier)" -ForegroundColor Magenta; $has = $true }
                if ($dl.FileDitch)   { Write-Host "      FILEDITCH: $($dl.FileDitch)"     -ForegroundColor Green;   $has = $true }
                if ($dl.OneFichier)  { Write-Host "      1FICHIER: $($dl.OneFichier)"     -ForegroundColor Red;     $has = $true }
                if ($dl.Vikingfile)  { Write-Host "      VIKINGFILE: $($dl.Vikingfile)"   -ForegroundColor Yellow;  $has = $true }
                if ($dl.MegaDB)      { Write-Host "      MEGADB: $($dl.MegaDB)"           -ForegroundColor Blue;    $has = $true }
                if (-not $has)       { Write-Host "      (no download links found)"       -ForegroundColor DarkGray }
            }

            if ($g.AnkerGames) {
                Write-Host "    [AnkerGames] $($g.AnkerGames.Url)" -ForegroundColor Magenta
            }
        }
        Write-Host ""
        continue
    }

    # substring search for queries longer than 3 chars
    foreach ($k in $unifiedGames.Keys) {
        if ($k.Contains($cleanInput)) { $found += $unifiedGames[$k] }
    }

    if ($found.Count -gt 0) {
        Write-Host "`nFound $($found.Count) match(es):" -ForegroundColor Green

        foreach ($g in $found) {
            Write-Host ""
            Write-Host " -- $($g.DisplayTitle)" -ForegroundColor Yellow

            if ($g.SteamRIP) {
                Write-Host "    [SteamRIP]   $($g.SteamRIP.Url)" -ForegroundColor Cyan
                $dl = Get-DownloadLinks -pageUrl $g.SteamRIP.Url
                $has = $false
                if ($dl.Gofile)      { Write-Host "      GOFILE: $($dl.Gofile)"           -ForegroundColor Cyan;    $has = $true }
                if ($dl.Buzzheavier) { Write-Host "      BUZZHEAVIER: $($dl.Buzzheavier)" -ForegroundColor Magenta; $has = $true }
                if ($dl.FileDitch)   { Write-Host "      FILEDITCH: $($dl.FileDitch)"     -ForegroundColor Green;   $has = $true }
                if ($dl.OneFichier)  { Write-Host "      1FICHIER: $($dl.OneFichier)"     -ForegroundColor Red;     $has = $true }
                if ($dl.Vikingfile)  { Write-Host "      VIKINGFILE: $($dl.Vikingfile)"   -ForegroundColor Yellow;  $has = $true }
                if ($dl.MegaDB)      { Write-Host "      MEGADB: $($dl.MegaDB)"           -ForegroundColor Blue;    $has = $true }
                if (-not $has)       { Write-Host "      (no download links found)"       -ForegroundColor DarkGray }
            }

            if ($g.AnkerGames) {
                Write-Host "    [AnkerGames] $($g.AnkerGames.Url)" -ForegroundColor Magenta
            }
        }
        Write-Host ""
    }
    else {
        Write-Host "No matches found for: $userInput" -ForegroundColor Red
    }
}