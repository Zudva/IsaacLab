#!/bin/bash

# Автоматическая настройка Isaac Lab DirectX Fork
# Использование: ./setup_fork.sh YOUR_GITHUB_USERNAME

GITHUB_USERNAME=$1
REPO_NAME=${2:-"IsaacLab-DirectX-Fork"}

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Ошибка: Укажите ваш GitHub username"
    echo "Использование: ./setup_fork.sh YOUR_GITHUB_USERNAME [REPO_NAME]"
    exit 1
fi

echo "🚀 Настройка Isaac Lab DirectX Fork для пользователя: $GITHUB_USERNAME"

# Проверка незафиксированных изменений
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  У вас есть незафиксированные изменения. Пожалуйста, сначала сделайте commit."
    exit 1
fi

# Получение текущей ветки
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Текущая ветка: $CURRENT_BRANCH"

# Переименование origin в upstream
echo "🔄 Переименование origin в upstream..."
if git remote rename origin upstream 2>/dev/null; then
    echo "✅ Origin переименован в upstream"
else
    echo "ℹ️  Origin уже переименован или не существует"
fi

# Добавление нового origin
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "🔗 Добавление нового origin: $REPO_URL"

if git remote add origin "$REPO_URL" 2>/dev/null; then
    echo "✅ Новый origin добавлен"
else
    echo "⚠️  Origin уже существует, обновляем URL..."
    git remote set-url origin "$REPO_URL"
    echo "✅ URL origin обновлен"
fi

# Проверка удаленных репозиториев
echo "📡 Настроенные удаленные репозитории:"
git remote -v

# Отправка текущей ветки на GitHub
echo "📤 Отправка ветки '$CURRENT_BRANCH' на GitHub..."
if git push -u origin "$CURRENT_BRANCH"; then
    echo "✅ Ветка '$CURRENT_BRANCH' успешно отправлена!"
else
    echo "❌ Ошибка при отправке. Проверьте:"
    echo "   1. Создан ли репозиторий $REPO_URL ?"
    echo "   2. Есть ли у вас права доступа к репозиторию?"
    echo "   3. Настроен ли SSH ключ или Personal Access Token?"
    exit 1
fi

# Создание и отправка main ветки (опционально)
echo "🌟 Создание main ветки с DirectX изменениями..."
if git checkout -b main 2>/dev/null && git push -u origin main; then
    echo "✅ Main ветка создана и отправлена!"
    git checkout "$CURRENT_BRANCH"
else
    echo "⚠️  Main ветка уже существует или ошибка создания"
fi

# Финальная информация
echo ""
echo "🎉 Настройка завершена успешно!"
echo "🔗 Ваш репозиторий: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "📁 Текущая ветка: $CURRENT_BRANCH"

echo ""
echo "📋 Следующие шаги:"
echo "   1. Перейдите в ваш GitHub репозиторий"
echo "   2. Обновите README_FORK.md (замените YOUR_USERNAME)"
echo "   3. Создайте Release с тегом v1.0.0"
echo "   4. Добавьте Topics: isaac-lab, directx, rtx-4090, robotics"

echo ""
echo "🛠️  Полезные команды:"
echo "   git remote -v              # Проверить удаленные репозитории"
echo "   git push origin main       # Отправить на GitHub"
echo "   git pull upstream main     # Получить обновления от Isaac Lab"

echo ""
echo "📚 Документация готова:"
echo "   - README_FORK.md          # Главный README форка"
echo "   - QUICK_START_DIRECTX.md  # Быстрый старт"
echo "   - COMMANDS_REFERENCE.md   # Справочник команд"
echo "   - README_RU.md            # Русская документация"
