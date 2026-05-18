# FastAPI CI/CD Lab

Простое web-приложение на FastAPI с тестами и автоматическим деплоем на Ubuntu сервер через GitHub Actions.

## Локальный запуск

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
uvicorn app.main:app --reload
```

Открыть приложение: `http://127.0.0.1:8000`

Запуск тестов:

```bash
pytest -q
```

## Как развернуть на Ubuntu

### 1. Подготовить сервер

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git nginx
```

### 2. Создать SSH ключ для GitHub Actions

На своем компьютере:

```bash
ssh-keygen -t ed25519 -C "github-actions-fastapi-lab" -f ./github-actions-fastapi-lab
```

Публичный ключ добавить на сервер:

```bash
ssh-copy-id -i ./github-actions-fastapi-lab.pub ubuntu@SERVER_IP
```

Приватный ключ `github-actions-fastapi-lab` понадобится добавить в GitHub Secrets.

### 3. Залить проект в GitHub

```bash
git init
git add .
git commit -m "Initial FastAPI CI/CD lab"
git branch -M main
git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

### 4. Склонировать проект на сервер

На сервере:

```bash
sudo mkdir -p /opt/fastapi-ci-cd-lab
sudo chown $USER:$USER /opt/fastapi-ci-cd-lab
git clone git@github.com:YOUR_USERNAME/YOUR_REPOSITORY.git /opt/fastapi-ci-cd-lab
cd /opt/fastapi-ci-cd-lab
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

Если репозиторий приватный, добавь SSH deploy key на GitHub или используй HTTPS с токеном.

### 5. Настроить systemd

```bash
sudo cp /opt/fastapi-ci-cd-lab/deploy/fastapi-ci-cd-lab.service /etc/systemd/system/fastapi-ci-cd-lab.service
sudo systemctl daemon-reload
sudo systemctl enable fastapi-ci-cd-lab
sudo systemctl start fastapi-ci-cd-lab
sudo systemctl status fastapi-ci-cd-lab
```

### 6. Настроить nginx

```bash
sudo cp /opt/fastapi-ci-cd-lab/deploy/nginx.conf /etc/nginx/sites-available/fastapi-ci-cd-lab
sudo ln -s /etc/nginx/sites-available/fastapi-ci-cd-lab /etc/nginx/sites-enabled/fastapi-ci-cd-lab
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

После этого приложение будет доступно по IP сервера: `http://SERVER_IP`

### 7. Настроить GitHub Secrets

В репозитории GitHub открыть `Settings -> Secrets and variables -> Actions -> New repository secret` и добавить:

- `SERVER_HOST` - IP адрес сервера
- `SERVER_USER` - пользователь на сервере, например `ubuntu`
- `SERVER_SSH_KEY` - приватный SSH ключ из файла `github-actions-fastapi-lab`
- `SERVER_PORT` - SSH порт, обычно `22`

### 8. Проверить CI/CD

Внеси любое изменение, затем:

```bash
git add .
git commit -m "Update app"
git push
```

GitHub Actions сначала запустит `pytest`. Если тесты пройдут успешно, workflow подключится к серверу по SSH, обновит файлы из ветки `main`, поставит зависимости и перезапустит `systemd` сервис.

## Полезные команды на сервере

```bash
sudo systemctl status fastapi-ci-cd-lab
sudo journalctl -u fastapi-ci-cd-lab -f
curl http://127.0.0.1:8000/health
```

