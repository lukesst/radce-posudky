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

# 2. Klonování nebo aktualizace repozitáře do C:\radce
Write-Host ""
if (Test-Path "C:\radce\.git") {
    Write-Host "📂 C:\radce existuje – aktualizuji soubory..."
    git -C C:\radce pull
} else {
    Write-Host "📥 Stahuji soubory do C:\radce..."
    git clone https://github.com/lukesst/radce-posudky.git C:\radce
}
Write-Host "✅ Soubory v C:\radce jsou aktuální"

# 3. Startup skript – automatický git pull při přihlášení
$startupFolder = [System.Environment]::GetFolderPath('Startup')
@"
@echo off
git -C C:\radce pull >nul 2>&1
"@ | Out-File "$startupFolder\radce_update.bat" -Encoding ascii
Write-Host "✅ Automatická aktualizace při spuštění PC nastavena"

Write-Host ""
Write-Host "=== Instalace dokončena ===" -ForegroundColor Green
Write-Host ""
Write-Host "Posledni krok – provest rucne v Claude Desktop:" -ForegroundColor Yellow
Write-Host "  Settings → MCP Connectors → Add → Filesystem"
Write-Host "  Cesta: C:\radce"
Write-Host ""
Write-Host "Pote restartuj Claude Desktop a otevri projekt Posudky."
Write-Host ""
Pause
