from aiogram import types, F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.utils.markdown import hbold

from bot.states import OrderStates
from models.user import register_user, load_users
from models.order import add_order, load_orders, save_orders

# /start
async def start_handler(message: types.Message):
    user = message.from_user
    is_new = register_user(user.id, user.full_name, user.username)
    if is_new:
        await message.answer("Добро пожаловать, новый пользователь! 🚚")
    else:
        await message.answer("С возвращением! Чем могу помочь?")

# /profile
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

# /help
ADMIN_IDS = [12345678]  # замените на свой user_id

async def help_handler(message: types.Message):
    text = (
        "🤖 Я бот доставки!\n\n"
        "Доступные команды:\n"
        "/start — регистрация или возврат в главное меню\n"
        "/profile — Ваш профиль\n"
        "/order — оформить заказ\n"
        "/pay — оплатить последний заказ\n"
        "/myorders — мои заказы\n"
        "/help — справка\n"
    )
    if message.from_user.id in ADMIN_IDS:
        text += "/allorders — все заказы (админ)\n"
    await message.answer(text)

# /users (для администратора, опционально)
async def users_handler(message: types.Message):
    if message.from_user.id not in ADMIN_IDS:
        await message.answer("⛔️ Доступ запрещён.")
        return
    users = load_users()
    if not users:
        await message.answer("Нет пользователей.")
    else:
        text = "Список пользователей:\n"
        for uid, info in users.items():
            text += f"{uid}: {info.get('full_name','-')} @{info.get('username','-')}\n"
        await message.answer(text)

# FSM: /order (старт)
async def order_start(message: types.Message, state: FSMContext):
    await message.answer("Опишите ваш заказ:")
    await state.set_state(OrderStates.waiting_for_description)

# FSM: описание заказа
async def order_description(message: types.Message, state: FSMContext):
    await state.update_data(description=message.text)
    await message.answer("Укажите адрес доставки:")
    await state.set_state(OrderStates.waiting_for_address)

# FSM: адрес доставки
async def order_address(message: types.Message, state: FSMContext):
    await state.update_data(address=message.text)
    await message.answer("Ваш контактный телефон:")
    await state.set_state(OrderStates.waiting_for_phone)

# FSM: телефон
async def order_phone(message: types.Message, state: FSMContext):
    await state.update_data(phone=message.text)
    await message.answer("Желаемое время доставки? (например, 14:30 или 'как можно скорее')")
    await state.set_state(OrderStates.waiting_for_time)

# FSM: желаемое время доставки
async def order_time(message: types.Message, state: FSMContext):
    await state.update_data(delivery_time=message.text)
    data = await state.get_data()
    text = (
        "Проверьте, пожалуйста, данные заказа:\n"
        f"📝 Заказ: {data.get('description')}\n"
        f"🏠 Адрес: {data.get('address')}\n"
        f"📞 Телефон: {data.get('phone')}\n"
        f"⏰ Время доставки: {data.get('delivery_time')}\n\n"
        "Если всё верно — напишите 'Да', если нужно изменить — напишите 'Нет'."
    )
    await message.answer(text)
    await state.set_state(OrderStates.waiting_for_confirmation)

# FSM: подтверждение
async def order_confirmation(message: types.Message, state: FSMContext):
    if message.text.lower() in ("да", "yes", "подтверждаю"):
        data = await state.get_data()
        order = {
            "user_id": message.from_user.id,
            "description": data.get("description"),
            "address": data.get("address"),
            "phone": data.get("phone"),
            "delivery_time": data.get("delivery_time"),
        }
        add_order(order)
        await message.answer(
            "Спасибо! Ваш заказ принят и передан на обработку. 🚚\n"
            "Чтобы оплатить заказ, используйте команду /pay."
        )
        await state.clear()
    else:
        await message.answer("Заказ отменён. Чтобы оформить новый, используйте /order.")
        await state.clear()

# /pay — оплата заказа (эмуляция)
async def pay_handler(message: types.Message):
    user_id = message.from_user.id
    orders = load_orders()
    unpaid_orders = [o for o in orders if o.get("user_id") == user_id and not o.get("paid")]
    if not unpaid_orders:
        await message.answer("У вас нет неоплаченных заказов.")
        return
    last_order = unpaid_orders[-1]
    last_order["paid"] = True
    save_orders(orders)
    await message.answer(
        "Ваш заказ был оплачен! Спасибо за доверие.\n"
        "Статус заказа: ОПЛАЧЕНО ✅"
    )

# /myorders — список заказов пользователя
async def myorders_handler(message: types.Message):
    user_id = message.from_user.id
    orders = load_orders()
    user_orders = [o for o in orders if o.get("user_id") == user_id]
    if not user_orders:
        await message.answer("У вас нет заказов.")
        return
    text = hbold("Ваши заказы:") + "\n"
    for idx, o in enumerate(user_orders, 1):
        text += (
            f"\n#{idx} — {'ОПЛАЧЕНО ✅' if o.get('paid') else 'Ожидает оплаты ❌'}\n"
            f"📝 {o.get('description')}\n"
            f"🏠 {o.get('address')}\n"
            f"⏰ {o.get('delivery_time')}\n"
            f"Создан: {o.get('created_at','-')}\n"
        )
    await message.answer(text)

# /allorders — только для администратора
async def allorders_handler(message: types.Message):
    if message.from_user.id not in ADMIN_IDS:
        await message.answer("⛔️ Доступ запрещён.")
        return
    orders = load_orders()
    if not orders:
        await message.answer("Заказов пока нет.")
        return
    text = hbold("Все заказы:") + "\n"
    for idx, o in enumerate(orders, 1):
        text += (
            f"\n#{idx} — {'ОПЛАЧЕНО ✅' if o.get('paid') else 'Ожидает оплаты ❌'}\n"
            f"Пользователь: {o.get('user_id')}\n"
            f"📝 {o.get('description')}\n"
            f"🏠 {o.get('address')}\n"
            f"⏰ {o.get('delivery_time')}\n"
            f"Создан: {o.get('created_at','-')}\n"
        )
    await message.answer(text)
