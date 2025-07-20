FROM python:3.10-slim

# Встановлюємо робочу директорію всередині контейнера
WORKDIR /app

# Копіюємо файл з залежностями
COPY requirements.txt .

# Встановлюємо залежності
RUN pip install --no-cache-dir -r requirements.txt

# Задаємо змінні середовища (беруться з .env через docker-compose)
ENV POSTGRES_HOST=${POSTGRES_HOST}
ENV POSTGRES_PORT=${POSTGRES_PORT}
ENV POSTGRES_NAME=${POSTGRES_NAME}
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}

# Копіюємо весь проєкт (включно з manage.py та проєктом Django)
COPY . .

# Команда за замовчуванням — запуск Django-сервера
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
