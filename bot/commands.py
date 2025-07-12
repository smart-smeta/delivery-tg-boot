from aiogram import types
from aiogram.filters.command import Command
from models.user import register_user, load_users

async def profile_handler(message: types.Message):
    users = load_users()
    user_id = str(message.from_user.id)
    if user_id in users:
        user_info = users[user_id]
        text = (
            f"🧑 Ваш профиль:\n"
            f"Имя: {user_info.get('full_name','-')}\n"
            f"Логин: @{user_info.get('username','-')}\n"
            f"Дата регистрации: {user_info.get('registered_at','-')}"
        )
    else:
        text = "Пользователь не найден. Используйте /start для регистрации."
    await message.answer(text)
