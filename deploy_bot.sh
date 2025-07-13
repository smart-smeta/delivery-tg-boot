#!/bin/bash

set -e

# Конфигурация
REPO_DIR="delivery-tg-boot"
REPO_URL="https://github.com/smart-smeta/delivery-tg-boot.git"
VENV_DIR="venv"
REQUIRED_PACKAGES=("aiogram" "python-dotenv" "loguru" "aiofiles")

# Функция для интерактивного создания .env файла
create_env_file() {
    echo ""
    echo "=== НАСТРОЙКА КОНФИГУРАЦИИ БОТА ==="
    
    # Запрос токена бота с валидацией
    while true; do
        echo ""
        read -p "Введите токен вашего Telegram бота (получите у @BotFather): " BOT_TOKEN
        
        # Проверка формата токена (примерный формат: 1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZ123456)
        if [[ "$BOT_TOKEN" =~ ^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$ ]]; then
            break
        else
            echo ""
            echo "ОШИБКА: Неверный формат токена!"
            echo "Пример правильного токена: 1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZ123456"
            echo "Пожалуйста, проверьте токен и попробуйте снова."
        fi
    done
    
    # Запрос ID администратора
    echo ""
    while true; do
        read -p "Введите ваш Telegram ID (можно узнать у @userinfobot): " ADMIN_ID
        
        # Проверка что ID состоит только из цифр
        if [[ "$ADMIN_ID" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "ОШИБКА: ID должен состоять только из цифр!"
        fi
    done
    
    # Запрос URL базы данных
    echo ""
    read -p "Введите URL базы данных [по умолчанию: sqlite:///bot/database.db]: " DATABASE_URL
    DATABASE_URL=${DATABASE_URL:-"sqlite:///bot/database.db"}
    
    # Создание файла .env
    {
        echo "# Конфигурация бота"
        echo "BOT_TOKEN=$BOT_TOKEN"
        echo "ADMIN_ID=$ADMIN_ID"
        echo "DATABASE_URL=$DATABASE_URL"
        echo ""
        echo "# Дополнительные настройки"
        echo "# DEBUG_MODE=True"
    } > ".env"
    
    echo ""
    echo "=== КОНФИГУРАЦИЯ УСПЕШНО СОХРАНЕНА ==="
    echo "Файл .env создан. Вы всегда можете отредактировать его: nano .env"
}

# Функция для проверки токена в .env
check_bot_token() {
    # Извлекаем токен из файла
    local TOKEN=$(grep '^BOT_TOKEN=' .env | cut -d '=' -f2-)
    
    # Проверяем формат токена
    if [[ "$TOKEN" =~ ^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$ ]]; then
        return 0
    else
        return 1
    fi
}

# 1. Установить системные зависимости
echo "Установка системных зависимостей..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git

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
    create_env_file
else
    echo ".env файл уже существует."
    
    # Проверяем токен на валидность
    if ! check_bot_token; then
        echo ""
        echo "ОШИБКА: Токен в .env файле неверный или имеет неверный формат!"
        read -p "Хотите обновить конфигурацию? [Y/n]: " choice
        
        if [[ "$choice" =~ ^[Yy]?$ ]]; then
            create_env_file
        else
            echo "Пожалуйста, проверьте токен вручную: nano .env"
            exit 1
        fi
    fi
fi

# 6. Проверка установки зависимостей
echo "Проверка установленных пакетов:"
pip list

# 7. Запуск бота
echo "Запуск бота..."
if python -c "import asyncio; from aiogram import Bot; from dotenv import load_dotenv; import os; load_dotenv(); token = os.getenv('BOT_TOKEN'); asyncio.run(Bot(token=token).get_me())" &> /dev/null; then
    echo "Токен валиден! Запускаем бота..."
    python -m bot.main
else
    echo ""
    echo "ОШИБКА: Неверный токен бота!"
    echo "Проверьте токен в .env файле и попробуйте снова."
    echo "Вы можете редактировать файл: nano .env"
    exit 1
fi
