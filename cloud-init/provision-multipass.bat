@echo off
setlocal EnableDelayedExpansion
:: =============================================================================
:: CR380 - Podman Lab — Multipass VM Provisioner (Windows)
:: =============================================================================
::
:: FR: Lance une VM Ubuntu 24.04 avec Multipass et la configure pour les labs.
::
:: EN: Launches an Ubuntu 24.04 VM with Multipass and configures it for the labs.
::
:: Prerequis / Prerequisites:
::   Multipass: https://multipass.run/install
::
:: Usage:
::   cloud-init\provision-multipass.bat
:: =============================================================================

:: ---------------------------------------------------------------------------
:: Variables
:: ---------------------------------------------------------------------------
set "VM_NAME=cr380-podman"
set "CLOUD_INIT=%~dp0user-data-fresh.yaml"

echo === CR380 Podman Lab — VM Provisioning ===
echo VM Name   : %VM_NAME%
echo Cloud-Init: %CLOUD_INIT%
echo.

:: ---------------------------------------------------------------------------
:: Check 1: Is multipass installed?
:: ---------------------------------------------------------------------------
where multipass >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: multipass not found.
    echo Install: https://multipass.run/install
    goto :fail
)

:: ---------------------------------------------------------------------------
:: Check 2: Does the cloud-init file exist?
:: ---------------------------------------------------------------------------
if not exist "%CLOUD_INIT%" (
    echo ERROR: Cloud-init file not found: %CLOUD_INIT%
    goto :fail
)

:: ---------------------------------------------------------------------------
:: Check 3: Idempotency — does the VM already exist?
:: ---------------------------------------------------------------------------
multipass info %VM_NAME% >nul 2>nul
if %errorlevel% equ 0 (
    echo INFO: VM "%VM_NAME%" already exists.
    echo   To connect : multipass shell %VM_NAME%
    echo   To rebuild : multipass delete %VM_NAME% --purge
    echo.
    goto :done
)

echo All checks passed. Launching VM...
echo.

:: ---------------------------------------------------------------------------
:: Launch VM
:: ---------------------------------------------------------------------------
multipass launch 24.04 --name %VM_NAME% --cloud-init "%CLOUD_INIT%" --cpus 2 --memory 4G --disk 20G
if %errorlevel% neq 0 (
    echo ERROR: multipass launch failed.
    goto :fail
)

echo.
echo VM launched. Waiting for cloud-init to complete...
echo.

:: ---------------------------------------------------------------------------
:: Poll for cloud-init completion (max 60 attempts x 5s = 5 minutes)
:: ---------------------------------------------------------------------------
set "ATTEMPTS=0"
set "MAX_ATTEMPTS=60"

:poll_loop
if !ATTEMPTS! geq %MAX_ATTEMPTS% (
    echo ERROR: cloud-init did not complete within 5 minutes.
    echo   Check manually: multipass exec %VM_NAME% -- cloud-init status
    goto :fail
)

multipass exec %VM_NAME% -- test -f /etc/cr380-ready >nul 2>nul
if %errorlevel% equ 0 goto :provision_ok

set /a ATTEMPTS+=1
echo   Waiting for cloud-init... [!ATTEMPTS!/%MAX_ATTEMPTS%]
timeout /t 5 /nobreak >nul
goto :poll_loop

:provision_ok
echo Cloud-init completed successfully.
echo.
echo ===========================================
echo  CR380 Podman Lab — VM prete / VM ready
echo ===========================================
echo.
echo Connect:  multipass shell %VM_NAME%
echo Then run: git clone ^<repo-url^> ^&^& cd CR380-podman-lab ^&^& ./run-labs.sh --learn
echo.
echo   User    : student
echo   Password: student
echo.
goto :done

:: ---------------------------------------------------------------------------
:: Exit handlers
:: ---------------------------------------------------------------------------
:fail
echo.
echo === Provisioning FAILED ===
endlocal
pause
exit /b 1

:done
echo.
echo === Done ===
endlocal
pause
exit /b 0
