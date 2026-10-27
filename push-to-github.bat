@echo off
chcp 65001 >nul
title Meo Xu - Đẩy code lên GitHub & Tự động Build APK/IPA
echo ========================================================
echo        🚀 MEO XU - PUSH TO GITHUB (GITHUB ACTIONS)
echo ========================================================
echo.

git rev-parse --is-inside-work-tree >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [1/3] Khởi tạo Git repository...
    git init
    git branch -M main
)

echo.
git remote get-url origin >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Chưa cấu hình remote GitHub cho dự án Meo Xu.
    echo Vui lòng tạo 1 repository mới trên GitHub (ví dụ: https://github.com/harryzikko/meoxu hoặc meoxu)
    set /p REPO_URL=">> Nhập URL GitHub repository của bạn: "
    if not "%REPO_URL%"=="" (
        git remote add origin %REPO_URL%
    ) else (
        echo [x] Chưa nhập URL remote. Dừng tiến trình.
        pause
        exit /b 1
    )
)

echo.
echo [2/3] Đang đóng gói và commit thay đổi...
git add .
git commit -m "feat: complete Meo Xu Phase A foundation, core features, parser, mascot & CI/CD workflow"

echo.
echo [3/3] Đang đẩy mã nguồn lên GitHub...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  ✅ PUSH THÀNH CÔNG!
    echo  GitHub Actions đang tự động biên dịch APK và IPA tại:
    echo  Kiểm tra tab Actions trên repository GitHub của bạn!
    echo ========================================================
) else (
    echo.
    echo ❌ Đẩy mã nguồn chưa thành công. Vui lòng kiểm tra quyền truy cập GitHub (SSH Key hoặc Token).
)

echo.
pause
