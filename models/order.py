import json
import os
from datetime import datetime

ORDERS_FILE = "orders.json"

def load_orders():
    if os.path.exists(ORDERS_FILE):
        with open(ORDERS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return []

def save_orders(orders):
    with open(ORDERS_FILE, "w", encoding="utf-8") as f:
        json.dump(orders, f, ensure_ascii=False, indent=4)

def add_order(order):
    order["created_at"] = datetime.now().isoformat()
    orders = load_orders()
    orders.append(order)
    save_orders(orders)
