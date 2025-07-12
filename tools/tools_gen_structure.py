import os

# Дерево проекта: ключ — папка, значение — список файлов/папок/словарей
tree = {
    "bot": [
        "__init__.py",
        "main.py",
        "commands.py",
        "middlewares.py",
        "states.py",
        "scheduler.py",
        "moderation.py",
        "analytics.py",
        "group_management.py",
        "ocr.py",
        "ai.py",
        {
            "i18n": [
                "__init__.py",
                {"ru": []},
                {"en": []}
            ]
        },
        {
            "payments": [
                "__init__.py",
                "payment_provider.py",
                "stripe.py",
                "yookassa.py",
                "tinkoff.py",
                "webhook.py",
                "pdf_receipt.py"
            ]
        }
    ],
    "delivery": [
        "__init__.py",
        "tracking.py",
        "checkin.py",
        "routes.py"
    ],
    "admin": [
        "__init__.py",
        "main.py",
        "auth.py",
        "users.py",
        "groups.py",
        "orders.py",
        "scheduler.py",
        "roles.py"
    ],
    "models": [
        "__init__.py",
        "user.py",
        "group.py",
        "order.py",
        "payment.py",
        "enums.py"
    ],
    "utils": [
        "__init__.py",
        "security.py",
        "logger.py",
        "validators.py"
    ],
    "tests": [],
}

top_level_files = [
    "postman_collection.json",
    "docker-compose.yml",
    "Dockerfile",
    "requirements.txt",
    "README.md"
]

def create_structure(base_path, tree_dict):
    for key, value in tree_dict.items():
        dir_path = os.path.join(base_path, key)
        os.makedirs(dir_path, exist_ok=True)
        for item in value:
            if isinstance(item, str):
                # Это файл
                file_path = os.path.join(dir_path, item)
                if not os.path.exists(file_path):
                    with open(file_path, "w", encoding="utf-8") as f:
                        if item.endswith("__init__.py"):
                            f.write("# init\n")
            elif isinstance(item, dict):
                # Это подпапка
                create_structure(dir_path, item)

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(base_dir, ".."))
    # Создаем структуру папок и файлов
    create_structure(project_root, tree)
    # Верхнеуровневые файлы
    for fname in top_level_files:
        fpath = os.path.join(project_root, fname)
        if not os.path.exists(fpath):
            with open(fpath, "w", encoding="utf-8") as f:
                if fname.endswith(".md"):
                    f.write("# README\n")
    print("Структура проекта создана!")

if __name__ == "__main__":
    main()
