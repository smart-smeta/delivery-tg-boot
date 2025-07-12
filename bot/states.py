from aiogram.fsm.state import StatesGroup, State

class OrderStates(StatesGroup):
    waiting_for_description = State()
    waiting_for_address = State()
    waiting_for_phone = State()
    waiting_for_time = State()
    waiting_for_confirmation = State()
