#!/bin/bash

set -e

# Конфигурация
REPO_DIR="delivery-tg-boot"
REPO_URL="https://github.com/smart-smeta/delivery-tg-boot.git"
VENV_DIR="venv"
REQUIRED_PACKAGES=("aiogram" "python-dotenv" "loguru" "aiofiles")

# 1. Установить системные зависимости
echo "Установка системных зависимостей..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git nano

# 2. Клонировать/обновить репозиторий
if [ ! -d "$REPO_DIR" ]; then
    echo "Клонирование репозитория..."
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
else
    echo "Обновление репозитория..."
    cd "$REPO_DIR"
    git pull
fi

# 3. Создать/активировать виртуальное окружение
if [ ! -d "$VENV_DIR" ]; then
    echo "Создание виртуального окружения..."
    python3 -m venv "$VENV_DIR"
fi

echo "Активация виртуального окружения..."
source "$VENV_DIR/bin/activate"

# 4. Установить зависимости Python
echo "Обновление pip..."
pip install --upgrade pip

# Проверка и установка обязательных пакетов
for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! python -c "import ${package}" &> /dev/null; then
        echo "Установка обязательного пакета ${package}..."
        pip install "$package"
    fi
done

# Дополнительная установка из requirements.txt (если есть)
if [ -f requirements.txt ]; then
    echo "Установка дополнительных зависимостей из requirements.txt..."
    pip install -r requirements.txt
fi

# Обновление файла зависимостей
echo "Обновление файла requirements.txt..."
pip freeze > requirements.txt

# 5. Настройка .env файла
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "Создание .env файла с настройками бота..."
    {
        echo "# Конфигурация бота"
        echo "BOT_TOKEN=ваш_токен_бота"
        echo "ADMIN_ID=ваш_telegram_id"
        echo "DATABASE_URL=sqlite:///bot/database.db"
        echo ""
        echo "# Дополнительные настройки"
        echo "# DEBUG_MODE=True"
    } > "$ENV_FILE"
    
    echo ""
    echo "Файл .env создан. Пожалуйста, отредактируйте его и добавьте реальный токен бота!"
    echo "Запустите скрипт снова после настройки токена"
    exit 1
else
    echo ".env файл уже существует."
    
    # Проверка токена
    if grep -q "BOT_TOKEN=ваш_токен_бота" "$ENV_FILE"; then
        echo "ОШИБКА: Вы забыли установить реальный токен бота в .env файле!"
        echo "Пожалуйста, отредактируйте .env файл:"
        echo "nano $ENV_FILE"
        echo "Замените 'ваш_токен_бота' на реальный токен"
        exit 1
    fi
fi

# 6. Проверка установки зависимостей
echo "Проверка установленных пакетов:"
pip list

# 7. Запуск бота
echo "Запуск бота..."
python -m bot.main
