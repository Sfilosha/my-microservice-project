#!/bin/bash

# Ubuntu / Debian

# Функція для перевірки наявності команди
command_exists () {
  type "$1" &> /dev/null ;
}

# Функція для встановлення пакетів, якщо вони не встановлені
install_packages_if_missing() {
  PACKAGES="$@"
  for pkg in $PACKAGES; do
    if dpkg -s "$pkg" &> /dev/null; then
      echo "$pkg вже встановлено раніше."
    else
      echo "Встановлюємо $pkg..."
      sudo apt-get install -y "$pkg" --no-install-recommends
    fi
  done
}

echo "Встановлення: Docker, Docker Compose, Python, Django"

# Встановлення Docker
echo "Checking if Docker exists..."
if ! command_exists docker; then
  echo "Docker not found. Installing Docker..."
  sudo apt-get update
  install_packages_if_missing ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  install_packages_if_missing docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"

  echo "Docker встановлено."
else
  echo "Docker вже встановлено раніше."
fi

# Встановлення Docker Compose
echo "Перевіряємо чи встановлений Docker Compose..."
if ! command_exists docker compose; then
  echo "Docker Compose не знайдено. Встановлюємо Docker Compose Standalone..."
  # Цей блок буде працювати, якщо Docker Compose не встановлено як плагін
  # Якщо ви бажаєте встановити старішу версію Docker Compose, замініть посилання
  DOCKER_COMPOSE_VERSION="v2.24.5"
  sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "Docker Compose (standalone) встановлено."
else
  echo "Docker Compose вже встановлено раніше."
fi


# Встановлення Python
echo "Перевіряємо встановлення Python..."
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null)
if [[ -z "$PYTHON_VERSION" || "$(echo -e "3.9\n$PYTHON_VERSION" | sort -V | head -n1)" != "3.9" ]]; then
  echo "Python 3.9 або новішої версії не знайдено. Встановлюємо Python..."
  sudo apt-get update
  install_packages_if_missing software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt-get update
  install_packages_if_missing python3.10 python3.10-venv python3.10-distutils
  sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
  echo "Python $PYTHON_VERSION встановлено."
else
  echo "Python $PYTHON_VERSION вже встановлено раніше."
fi

# Встановлення pip3
echo "Перевіряємо чи встановлений pip3..."
if ! command_exists pip3; then
  echo "pip3 не знайдено. Встановлюємо..."
  install_packages_if_missing python3-pip
else
  echo "pip3 вже встановлено раніше."
fi

# Встановлення Django
echo "Перевіряємо чи встановлений Django..."
if python3 -c "import django" &> /dev/null; then
  DJANGO_VERSION=$(python3 -c "import django; print(django.get_version())")
  echo "Django вже встановлено раніше. Версія: $DJANGO_VERSION"
else
  echo "Django не знайдено. Встановлюємо..."
  pip3 install Django
  echo "Django встановлено."
fi

echo "Встановлення всіх інструментів завершено."