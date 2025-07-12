from aiogram import types
from aiogram.filters.command import Command
from models.user import register_user

async def start_handler(message: types.Message):
    user = message.from_user
    is_new = register_user(
        user_id=user.id,
        full_name=user.full_name,
        username=user.username
    )
    if is_new:
        await message.answer("Добро пожаловать, новый пользователь! 🚚")
    else:
        await message.answer("С возвращением! Чем могу помочь?")