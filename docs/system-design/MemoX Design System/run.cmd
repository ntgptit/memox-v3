@echo off
REM ── MemoX Design System — local launcher ────────────────────────────────
REM Static gallery (React UMD + Babel from CDN). Needs an HTTP server + internet.
REM Double-click this file, or run it from a terminal.

setlocal
set "PORT=8753"
set "URL=http://127.0.0.1:%PORT%/ui_kits/mobile/index.html"

REM Serve from THIS folder (index.html links ../../colors_and_type.css)
cd /d "%~dp0"

echo.
echo   MemoX Design System
echo   Serving %~dp0
echo   Open: %URL%
echo   (Press Ctrl+C to stop)
echo.

REM Open the browser shortly after the server comes up
start "" /b cmd /c "timeout /t 1 >nul & start "" "%URL%""

REM Prefer Python; fall back to Node's http-server via npx
where python >nul 2>&1
if %errorlevel%==0 (
  python -m http.server %PORT% --bind 127.0.0.1
) else (
  npx --yes http-server -p %PORT% -a 127.0.0.1 .
)

endlocal
