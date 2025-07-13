#!/bin/bash

set -e

# 1. Установить зависимости системы
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git

# 2. Клонировать репозиторий (замени ссылку на свой!)
git clone https://github.com/smart-smeta/delivery-tg-boot.git
cd delivery-tg-boot

# 3. Создать виртуальное окружение и установить зависимости
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

# Если есть requirements.txt:
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# 4. (Опционально) Создать .env файл с переменными окружения
if [ ! -f .env ]; then
    echo "Создайте .env с настройками бота, например:"
    echo "BOT_TOKEN=ваш_токен" > .env
fi

# 5. Запуск бота
echo "Для запуска бота выполните:"
echo "source venv/bin/activate"
echo "python main.py"
