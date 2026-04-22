# Posudkový rádce – instalační skript
# Spustit v PowerShell jako administrátor
# Stažení a spuštění jedním příkazem:
#   irm https://raw.githubusercontent.com/lukesst/radce-posudky/main/install.ps1 | iex

Write-Host "=== Posudkový rádce – instalace ===" -ForegroundColor Cyan
Write-Host ""

# 1. Kontrola git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git není nainstalován." -ForegroundColor Red
    Write-Host "   Stáhni z: https://git-scm.com/download/win"
    Write-Host "   Po instalaci gitu spusť tento skript znovu."
    Pause; exit 1
}
Write-Host "✅ Git: $(git --version)"

# 2. Kontrola Node.js (nutné pro filesystem MCP)
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js není nainstalován." -ForegroundColor Red
    Write-Host "   Stáhni z: https://nodejs.org (LTS verze)"
    Write-Host "   Po instalaci Node.js spusť tento skript znovu."
    Pause; exit 1
}
Write-Host "✅ Node.js: $(node --version)"

# 3. Klonování nebo aktualizace repozitáře do C:\radce
Write-Host ""
if (Test-Path "C:\radce\.git") {
    Write-Host "📂 C:\radce existuje – aktualizuji soubory..."
    git -C C:\radce pull
} else {
    Write-Host "📥 Stahuji soubory do C:\radce..."
    git clone https://github.com/lukesst/radce-posudky.git C:\radce
}
Write-Host "✅ Soubory v C:\radce jsou aktuální"

# 4. Startup skript – automatický git pull při přihlášení
$startupFolder = [System.Environment]::GetFolderPath('Startup')
@"
@echo off
git -C C:\radce pull >nul 2>&1
"@ | Out-File "$startupFolder\radce_update.bat" -Encoding ascii
Write-Host "✅ Automatická aktualizace při spuštění PC nastavena"

# 5. Claude Desktop – filesystem MCP konfigurace
$claudeConfig = "$env:APPDATA\Claude\claude_desktop_config.json"
$mcpEntry = [ordered]@{
    command = "npx"
    args    = @("-y", "@modelcontextprotocol/server-filesystem", "C:\radce")
}

if (Test-Path $claudeConfig) {
    $raw = Get-Content $claudeConfig -Raw
    $config = $raw | ConvertFrom-Json
    if (-not $config.mcpServers) {
        $config | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([PSCustomObject]@{})
    }
    $config.mcpServers | Add-Member -NotePropertyName filesystem -NotePropertyValue $mcpEntry -Force
    $config | ConvertTo-Json -Depth 10 | Out-File $claudeConfig -Encoding utf8NoBOM
    Write-Host "✅ Claude Desktop MCP konfigurace aktualizována"
} else {
    New-Item -ItemType Directory -Force -Path "$env:APPDATA\Claude" | Out-Null
    [PSCustomObject]@{ mcpServers = [PSCustomObject]@{ filesystem = $mcpEntry } } |
        ConvertTo-Json -Depth 10 | Out-File $claudeConfig -Encoding utf8NoBOM
    Write-Host "✅ Claude Desktop MCP konfigurace vytvořena"
}

Write-Host ""
Write-Host "=== Instalace dokončena ===" -ForegroundColor Green
Write-Host ""
Write-Host "Dalsi krok: Restartuj Claude Desktop." -ForegroundColor Yellow
Write-Host "Pote otevri projekt Posudky a over ze Claude vidi soubory v C:\radce"
Write-Host ""
Pause
