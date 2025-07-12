import asyncio
import logging
import os

from aiogram import Bot, Dispatcher
from aiogram.fsm.storage.memory import MemoryStorage
from aiogram.filters import Command

from dotenv import load_dotenv

from bot.commands import (
    start_handler, profile_handler, help_handler, users_handler,
    order_start, order_description, order_address, order_phone, order_time,
    order_confirmation, pay_handler
)
from bot.states import OrderStates

load_dotenv()
TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
logging.basicConfig(level=logging.INFO)

async def main():
    if not TOKEN:
        raise ValueError("Не задан токен бота. Установите переменную окружения TELEGRAM_BOT_TOKEN")

    bot = Bot(token=TOKEN)
    dp = Dispatcher(storage=MemoryStorage())

    # Регистрация хендлеров
    dp.message.register(start_handler, Command("start"))
    dp.message.register(profile_handler, Command("profile"))
    dp.message.register(help_handler, Command("help"))
    dp.message.register(users_handler, Command("users"))

    # FSM order
    dp.message.register(order_start, Command("order"))
    dp.message.register(order_description, OrderStates.waiting_for_description)
    dp.message.register(order_address, OrderStates.waiting_for_address)
    dp.message.register(order_phone, OrderStates.waiting_for_phone)
    dp.message.register(order_time, OrderStates.waiting_for_time)
    dp.message.register(order_confirmation, OrderStates.waiting_for_confirmation)

    # Оплата
    dp.message.register(pay_handler, Command("pay"))

    await dp.start_polling(bot)

if __name__ == "__main__":
    asyncio.run(main())
