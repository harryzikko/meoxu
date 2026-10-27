@echo off
chcp 65001 >nul
title Meo Xu - Push to GitHub
echo ========================================================
echo        🚀 PUSH MÃ NGUỒN MEO XU LÊN GITHUB
echo ========================================================
echo.

git remote get-url origin >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    git remote add origin git@github.com:harryzikko/meoxu.git
)

git config core.sshCommand "ssh -i C:/Users/tigon/.ssh/id_ed25519_meoxu -o StrictHostKeyChecking=accept-new"

echo Đang đẩy mã nguồn lên branch main...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  ✅ PUSH THÀNH CÔNG!
    echo  GitHub Actions đang tự động biên dịch APK & IPA tại:
    echo  https://github.com/harryzikko/meoxu/actions
    echo ========================================================
) else (
    echo.
    echo ❌ Chưa thể push code lên GitHub.
    echo Bạn hãy kiểm tra đã thêm Public Deploy Key vào repo chưa:
    echo https://github.com/harryzikko/meoxu/settings/keys
    echo (Nhớ tích chọn "Allow write access")
)

echo.
pause
