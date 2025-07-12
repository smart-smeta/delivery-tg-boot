from aiogram import types
from aiogram.filters.command import Command
from models.user import register_user, load_users

async def help_handler(message: types.Message):
    text = (
        "🤖 Я бот доставки!\n\n"
        "Доступные команды:\n"
        "/start — регистрация или возврат в главное меню\n"
        "/profile — Ваш профиль\n"
        "/help — справка\n"
        # Здесь позже появятся другие команды
    )
    await message.answer(text)
