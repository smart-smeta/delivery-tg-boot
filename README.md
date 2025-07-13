# Telegram Delivery Bot

Этот проект — многофункциональный Telegram-бот для автоматизации доставки, управления заказами, группами, платежами и аналитикой. Проект реализован на Python и организован по модульной структуре для удобства масштабирования и поддержки.

## Возможности

- **Управление пользователями и группами**
- **Оформление и отслеживание заказов**
- **Интеграция с платёжными системами** (Stripe, YooKassa, Tinkoff)
- **Модерация и аналитика**
- **Многоязычный интерфейс** (русский/английский)
- **AI и OCR-модули**
- **Гибкое администрирование**

## Структура проекта

```
bot/              - основной код Telegram-бота
    main.py       - точка входа
    ...
delivery/         - логика доставки и маршрутизация
admin/            - административные функции
models/           - ORM-модели
utils/            - утилиты и вспомогательные функции
tests/            - autotests
```

## Быстрый старт

1. **Установите зависимости:**
   ```sh
   pip install -r requirements.txt
   ```

2. **Настройте переменные окружения:**
   - Создайте `.env` файл или экспортируйте необходимые переменные (токен Telegram, ключи платежных систем и т.д.)

3. **Запустите бота:**
   ```sh
   python bot/main.py
   ```

## Используемые технологии

- Python 3.10+
- aiogram (или другой фреймворк для Telegram-ботов)
- SQLAlchemy или другой ORM
- Stripe, YooKassa, Tinkoff (платежи)
- Docker (опционально)
- Postgres/MySQL (опционально)

## Разработка и вклад

PR и предложения приветствуются!  
Перед отправкой изменений запускайте тесты и следуйте принятому стилю кодирования.

## Лицензия

Проект распространяется под MIT License.


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
