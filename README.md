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


# Быстрый запуск Telegram-бота с помощью скрипта deploy_bot.sh

## 1. Требования

- Виртуальная машина или сервер с Debian 12
- Права sudo (или root)
- Установлен git (если нет — будет установлен автоматически)
- Токен Telegram-бота (получить у BotFather)

## 2. Клонирование репозитория

```bash
git clone https://github.com/smart-smeta/delivery-tg-boot.git
cd delivery-tg-boot
```

## 3. Запуск скрипта автоматической установки

Скрипт **deploy_bot.sh** установит все нужные зависимости, создаст виртуальное окружение, установит Python-библиотеки и подготовит проект к запуску.

```bash
chmod +x deploy_bot.sh
./deploy_bot.sh
```

## 4. Настройка переменных окружения

Скрипт создаст файл `.env`, если его нет. Откройте его и впишите ваш токен:

```
BOT_TOKEN=ваш_токен_бота
```

Добавьте другие переменные, если они требуются вашим ботом (например, настройки базы данных).

## 5. Запуск бота

После установки и настройки переменных окружения, активируйте виртуальное окружение и запустите бота:

```bash
source venv/bin/activate
python main.py
```

## 6. (По желанию) Автоматический запуск через systemd

Для автозапуска и мониторинга вы можете использовать systemd. Пример юнита:

```ini
[Unit]
Description=Delivery Telegram Bot
After=network.target

[Service]
Type=simple
User=имя_пользователя
WorkingDirectory=/путь/до/delivery-tg-boot
EnvironmentFile=/путь/до/delivery-tg-boot/.env
ExecStart=/путь/до/delivery-tg-boot/venv/bin/python /путь/до/delivery-tg-boot/main.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

1. Сохраните как `/etc/systemd/system/delivery-tg-bot.service`
2. Перезагрузите systemd и запустите бот:

```bash
sudo systemctl daemon-reload
sudo systemctl enable delivery-tg-bot
sudo systemctl start delivery-tg-bot
sudo systemctl status delivery-tg-bot
```

---

**Контакты для вопросов:**  
Если возникли ошибки или вопросы — обращайтесь к README проекта или напрямую к разработчику.
