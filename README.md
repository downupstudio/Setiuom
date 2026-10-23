# Setiuom

In January 2026 I wrote a script called SteamRIP Checker that checked game availability on SteamRIP. I did it to avoid the malicious ads. It eventually stopped working because of Cloudflare. In October 2026, as a better programmer, I fixed it and based Setiuom on it.

## What It Is

A PowerShell game search tool. Type a game name, get links from multiple game sites in one place. Shows direct download links where available.

## How to Use It

Paste this into your terminal and hit enter:

```powershell
Invoke-Expression (Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/downupstudio/Setiuom/refs/heads/main/setiuom.ps1).Content
```

Then type any game name and press Enter. Type `exit` to quit.

# Version History

## alpha
*2026-01-13*
- First SteamRIP script
- Search SteamRIP game list
- Extract download links from Gofile, Buzzheavier, FileDitch, 1Fichier, Vikingfile, MegaDB

## 1.0
*2026-10-22*
- Added AnkerGames support
- Unified search across all supported sites
- Merged duplicate results (one game, links from every site it appears on)
- Title normalization so matching works across sites
- 403 recovery via curl.exe fallback

## 1.1
*2026-10-23*
- 1-3 character search words now match by first word.
- Stopword filtering so "a", "the", "of" don't cause false matches.
- Removed the manual exceptions list, and the nba -> nba 2k hack. The first-word lookup now covers both of them.
