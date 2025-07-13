#!/bin/bash

set -e

# Конфигурация
REPO_DIR="delivery-tg-boot"
REPO_URL="https://github.com/smart-smeta/delivery-tg-boot.git"
VENV_DIR="venv"
REQUIRED_PACKAGES=("aiogram" "python-dotenv" "loguru" "aiofiles")

# Функция для интерактивного создания .env файла
create_env_file() {
    echo "Создание конфигурационного файла .env..."
    echo ""
    
    # Запрос токена бота
    read -p "Введите токен вашего Telegram бота (получите у @BotFather): " BOT_TOKEN
    while [ -z "$BOT_TOKEN" ]; do
        echo "Токен бота не может быть пустым!"
        read -p "Введите токен вашего Telegram бота: " BOT_TOKEN
    done
    
    # Запрос ID администратора
    read -p "Введите ваш Telegram ID (можно узнать у @userinfobot): " ADMIN_ID
    while [ -z "$ADMIN_ID" ]; do
        echo "ID администратора не может быть пустым!"
        read -p "Введите ваш Telegram ID: " ADMIN_ID
    done
    
    # Запрос URL базы данных
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
    echo "Файл .env успешно создан!"
    echo "Вы всегда можете отредактировать его вручную: nano .env"
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
    
    # Проверка токена
    if grep -q "BOT_TOKEN=ваш_токен_бота" "$ENV_FILE" || ! grep -q "BOT_TOKEN=" "$ENV_FILE"; then
        echo "ВНИМАНИЕ: Токен бота не настроен или установлен по умолчанию!"
        read -p "Хотите обновить конфигурацию сейчас? [y/N]: " choice
        
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            create_env_file
        fi
    fi
fi

# 6. Проверка установки зависимостей
echo "Проверка установленных пакетов:"
pip list

# 7. Запуск бота
echo "Запуск бота..."
python -m bot.main
