import asyncio
import logging
import os

from aiogram import Bot, Dispatcher
from aiogram.filters.command import Command
from dotenv import load_dotenv

from bot.commands import start_handler

load_dotenv()
TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")

logging.basicConfig(level=logging.INFO)

async def main():
    if not TOKEN:
        raise ValueError("Не задан токен бота. Установите переменную окружения TELEGRAM_BOT_TOKEN")

    bot = Bot(token=TOKEN)
    dp = Dispatcher()

    dp.message.register(start_handler, Command("start"))
    dp.message.register(profile_handler, Command("profile"))
    dp.message.register(help_handler, Command("help"))

    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
