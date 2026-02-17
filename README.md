# SteamRIP Checker

## How to Run It

Just paste this into your terminal and hit enter:

```powershell
Invoke-Expression (Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/downupstudio/SteamRIP-Checker/refs/heads/main/steamripchecker.ps1).Content
```

## What It Does

*   **Grabs Info:** It gets the game list from SteamRIP.
*   **Sorts the Data:** It downloads that list and gets it ready to be used.
*   **Makes a List:** Then, it makes a list on your computer with all the game names and links.
*   **Lets You Search:** You can type in the console to find games.
*   **Finds Your Game:** It searches all the games super fast.
*   **Shows the Results:** It shows you the games that match and their links.
*   **Handles Weird Characters:** It deals with special characters so they look right. 

## Technical Stuff

*   **Fixes Problems:** It has code that tries to fix things if the website isn't working.
*   **Keeps Things Speedy:** It's made to handle a lot of info without slowing down your computer.
*   **Looks Good:** It's got a nice, simple design and uses colors.
*   **Quick Search:** It finds what you're looking for fast.
*   **Quitting:** You can type a command to close it down properly.

## What You Need

*   **OS:** Windows 10 or 11.
*   **PowerShell:** PowerShell 5.1 or newer (the one that comes with Windows).
*   **.NET:** .NET Framework 4.7.2 or higher.
*   **Internet:** You have to be online to get the game list.

## Important Stuff

*   It's polite to the website. It only asks for the game list once.
*   This is just for learning. Don't do anything that breaks the website's rules or copyright laws.
*   Some symbols in the game titles might look weird because of your console's settings.
