# Инструкция по развертыванию Telegram-бота на сервере Debian 12

## 1. Предварительные требования

- Чистая VM с Debian 12 (или аналогичной ОС)
- Права суперпользователя (sudo)
- Установлен git
- Получен токен Telegram-бота (у BotFather)
- (Необязательно) Данные для подключения к СУБД или сторонним сервисам

## 2. Установка зависимостей

```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git
```

## 3. Клонирование репозитория

```bash
git clone https://github.com/smart-smeta/delivery-tg-boot.git
cd delivery-tg-boot
```

## 4. Создание виртуального окружения и установка зависимостей

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## 5. Настройка переменных окружения

Создайте файл `.env` в корне проекта (если требуется), например:

```
BOT_TOKEN=ваш_токен_бота
# Другие переменные, если нужны (например, данные для СУБД)
```

## 6. Первый запуск

```bash
source venv/bin/activate
python main.py
```

## 7. (Рекомендуется) Автоматический запуск через systemd

Пример юнита systemd:

```ini
[Unit]
Description=Delivery Telegram Bot
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/path/to/delivery-tg-boot
EnvironmentFile=/path/to/delivery-tg-boot/.env
ExecStart=/path/to/delivery-tg-boot/venv/bin/python /path/to/delivery-tg-boot/main.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

1. Сохраните как `/etc/systemd/system/delivery-tg-bot.service`
2. Выполните:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable delivery-tg-bot
   sudo systemctl start delivery-tg-bot
   sudo systemctl status delivery-tg-bot
   ```

---

**Если возникли вопросы — смотрите README проекта или обратитесь к разработчику.**
