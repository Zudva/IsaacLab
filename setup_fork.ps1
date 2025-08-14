# Автоматическая настройка Isaac Lab DirectX Fork
# Для использования: замените YOUR_GITHUB_USERNAME на ваш GitHub username

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername,
    
    [Parameter(Mandatory=$false)]
    [string]$RepoName = "IsaacLab-DirectX-Fork"
)

Write-Host "🚀 Настройка Isaac Lab DirectX Fork для пользователя: $GitHubUsername" -ForegroundColor Green

# Проверка текущего состояния git
Write-Host "📋 Проверка состояния git..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  У вас есть незафиксированные изменения. Пожалуйста, сначала сделайте commit." -ForegroundColor Red
    exit 1
}

# Проверка текущей ветки
$currentBranch = git branch --show-current
Write-Host "📍 Текущая ветка: $currentBranch" -ForegroundColor Cyan

# Переименование origin в upstream
Write-Host "🔄 Переименование origin в upstream..." -ForegroundColor Yellow
try {
    git remote rename origin upstream 2>$null
    Write-Host "✅ Origin переименован в upstream" -ForegroundColor Green
} catch {
    Write-Host "ℹ️  Origin уже переименован или не существует" -ForegroundColor Blue
}

# Добавление нового origin
$repoUrl = "https://github.com/$GitHubUsername/$RepoName.git"
Write-Host "🔗 Добавление нового origin: $repoUrl" -ForegroundColor Yellow

try {
    git remote add origin $repoUrl
    Write-Host "✅ Новый origin добавлен" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Origin уже существует, обновляем URL..." -ForegroundColor Yellow
    git remote set-url origin $repoUrl
    Write-Host "✅ URL origin обновлен" -ForegroundColor Green
}

# Проверка удаленных репозиториев
Write-Host "📡 Настроенные удаленные репозитории:" -ForegroundColor Cyan
git remote -v

# Отправка текущей ветки на GitHub
Write-Host "📤 Отправка ветки '$currentBranch' на GitHub..." -ForegroundColor Yellow
try {
    git push -u origin $currentBranch
    Write-Host "✅ Ветка '$currentBranch' успешно отправлена!" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка при отправке. Проверьте:" -ForegroundColor Red
    Write-Host "   1. Создан ли репозиторий $repoUrl ?" -ForegroundColor Red
    Write-Host "   2. Есть ли у вас права доступа к репозиторию?" -ForegroundColor Red
    Write-Host "   3. Настроен ли SSH ключ или Personal Access Token?" -ForegroundColor Red
    exit 1
}

# Создание и отправка main ветки (опционально)
Write-Host "🌟 Создание main ветки с DirectX изменениями..." -ForegroundColor Yellow
try {
    git checkout -b main 2>$null
    git push -u origin main
    Write-Host "✅ Main ветка создана и отправлена!" -ForegroundColor Green
    
    # Возврат к исходной ветке
    git checkout $currentBranch
} catch {
    Write-Host "⚠️  Main ветка уже существует или ошибка создания" -ForegroundColor Yellow
}

# Финальная информация
Write-Host ""
Write-Host "🎉 Настройка завершена успешно!" -ForegroundColor Green
Write-Host "🔗 Ваш репозиторий: https://github.com/$GitHubUsername/$RepoName" -ForegroundColor Cyan
Write-Host "📁 Текущая ветка: $currentBranch" -ForegroundColor Blue

Write-Host ""
Write-Host "📋 Следующие шаги:" -ForegroundColor Yellow
Write-Host "   1. Перейдите в ваш GitHub репозиторий" -ForegroundColor White
Write-Host "   2. Обновите README_FORK.md (замените YOUR_USERNAME)" -ForegroundColor White
Write-Host "   3. Создайте Release с тегом v1.0.0" -ForegroundColor White
Write-Host "   4. Добавьте Topics: isaac-lab, directx, rtx-4090, robotics" -ForegroundColor White

Write-Host ""
Write-Host "🛠️  Полезные команды:" -ForegroundColor Cyan
Write-Host "   git remote -v              # Проверить удаленные репозитории" -ForegroundColor Gray
Write-Host "   git push origin main       # Отправить на GitHub" -ForegroundColor Gray
Write-Host "   git pull upstream main     # Получить обновления от Isaac Lab" -ForegroundColor Gray

Write-Host ""
Write-Host "📚 Документация готова:" -ForegroundColor Green
Write-Host "   - README_FORK.md          # Главный README форка" -ForegroundColor Gray
Write-Host "   - QUICK_START_DIRECTX.md  # Быстрый старт" -ForegroundColor Gray
Write-Host "   - COMMANDS_REFERENCE.md   # Справочник команд" -ForegroundColor Gray
Write-Host "   - README_RU.md            # Русская документация" -ForegroundColor Gray
