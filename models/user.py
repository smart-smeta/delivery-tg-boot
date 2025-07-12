import json
import os
from datetime import datetime

USERS_FILE = "users.json"

def load_users():
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}

def save_users(users):
    with open(USERS_FILE, "w", encoding="utf-8") as f:
        json.dump(users, f, ensure_ascii=False, indent=4)

def register_user(user_id, full_name, username):
    users = load_users()
    if str(user_id) not in users:
        users[str(user_id)] = {
            "full_name": full_name,
            "username": username,
            "registered_at": datetime.now().isoformat()
        }
        save_users(users)
        return True
    return False