# Руководство по развертыванию Lab 6 на Windows

Это руководство предназначено для пользователей Windows, у которых могут возникнуть проблемы при использовании стандартного скрипта `deploy.sh`.

## Проблема

При запуске `./deploy.sh` на Windows (Git Bash/MINGW64) может возникнуть ошибка Python traceback при выполнении команды `ansible`. Это связано с особенностями работы Ansible на Windows.

## Решение 1: Использование WSL2 (Рекомендуется)

### Установка WSL2

1. Откройте PowerShell от имени администратора и выполните:
   ```powershell
   wsl --install
   ```

2. Перезагрузите компьютер

3. Установите Ubuntu из Microsoft Store (если не установилось автоматически)

4. Запустите Ubuntu и создайте пользователя

### Установка необходимых инструментов в WSL

```bash
# Обновление пакетов
sudo apt update && sudo apt upgrade -y

# Установка Ansible
sudo apt install -y ansible

# Установка Python и pip
sudo apt install -y python3 python3-pip

# Проверка установки
ansible --version
```

### Доступ к проекту из WSL

```bash
# Перейдите в директорию проекта (замените путь на свой)
cd /mnt/d/Subjects/Мага/infrasture-as-a-code/lab6

# Запустите развертывание
./deploy.sh
```

## Решение 2: Ручное развертывание

Если WSL недоступен, можно выполнить развертывание вручную:

### Шаг 1: Запуск виртуальных машин

Откройте Git Bash или PowerShell в директории `lab6`:

```bash
vagrant up
```

Дождитесь завершения запуска обеих VM (app и monitoring).

### Шаг 2: Проверка доступности VM

```bash
# Проверка app VM
vagrant ssh app -c "echo 'App VM is ready'"

# Проверка monitoring VM
vagrant ssh monitoring -c "echo 'Monitoring VM is ready'"
```

Обе команды должны вывести сообщение об успешном подключении.

### Шаг 3: Развертывание через Ansible

Есть несколько вариантов:

#### Вариант A: Через WSL (если установлен)

```bash
# В WSL терминале
cd /mnt/d/Subjects/Мага/infrasture-as-a-code/lab6
ansible-playbook -i inventories/hosts.ini deploy.yml
```

#### Вариант B: Через Git Bash с установленным Ansible

```bash
ansible-playbook -i inventories/hosts.ini deploy.yml
```

#### Вариант C: Через PowerShell с установленным Ansible

```powershell
ansible-playbook -i inventories/hosts.ini deploy.yml
```

### Шаг 4: Проверка развертывания

После успешного выполнения playbook проверьте доступность сервисов:

- Grafana: http://192.168.56.31:3000 (admin/admin)
- Prometheus: http://192.168.56.31:9090
- Application: http://192.168.56.30:8080
- Alertmanager: http://192.168.56.31:9093

## Решение 3: Установка Ansible на Windows

### Через Python pip

1. Установите Python 3.8+ (если не установлен): https://www.python.org/downloads/

2. Установите Ansible через pip:
   ```bash
   pip install ansible
   ```

3. Проверьте установку:
   ```bash
   ansible --version
   ```

4. Запустите развертывание:
   ```bash
   cd lab6
   ansible-playbook -i inventories/hosts.ini deploy.yml
   ```

## Альтернативный подход: Развертывание по частям

Если полное автоматическое развертывание не работает, можно развернуть компоненты по отдельности:

### 1. Развертывание приложения

```bash
ansible-playbook -i inventories/hosts.ini deploy.yml --limit app
```

### 2. Развертывание мониторинга

```bash
ansible-playbook -i inventories/hosts.ini deploy.yml --limit monitoring
```

### 3. Развертывание отдельных ролей

```bash
# Только Prometheus
ansible-playbook -i inventories/hosts.ini deploy.yml --tags prometheus

# Только Grafana
ansible-playbook -i inventories/hosts.ini deploy.yml --tags grafana

# Только Alertmanager
ansible-playbook -i inventories/hosts.ini deploy.yml --tags alertmanager
```

## Распространенные ошибки

### Ошибка: "Python traceback" при запуске ansible

**Причина**: Ansible плохо работает в Git Bash на Windows.

**Решение**: 
- Используйте WSL2 (Решение 1)
- Или установите Ansible через pip и используйте PowerShell

### Ошибка: "ansible: command not found"

**Причина**: Ansible не установлен или не в PATH.

**Решение**:
```bash
# В WSL
sudo apt install ansible

# В Windows через pip
pip install ansible
```

### Ошибка: "Permission denied" при доступе к private_key

**Причина**: Неправильные права доступа к SSH ключам.

**Решение** (в WSL):
```bash
chmod 600 .vagrant/machines/*/virtualbox/private_key
```

### Ошибка: "Could not resolve hostname"

**Причина**: VM не запущены или неправильный инвентарь.

**Решение**:
1. Проверьте статус VM: `vagrant status`
2. Запустите VM: `vagrant up`
3. Проверьте файл `inventories/hosts.ini`

## Проверка успешного развертывания

После завершения развертывания выполните следующие проверки:

### 1. Проверка статуса сервисов на app сервере

```bash
vagrant ssh app
sudo systemctl status spring-boot-app
```

Должно быть: `Active: active (running)`

### 2. Проверка статуса сервисов на monitoring сервере

```bash
vagrant ssh monitoring
sudo systemctl status prometheus
sudo systemctl status grafana-server
sudo systemctl status alertmanager
sudo systemctl status loki
```

Все сервисы должны быть `Active: active (running)`

### 3. Проверка web-интерфейсов

Откройте в браузере:
- http://192.168.56.31:3000 - Grafana (admin/admin)
- http://192.168.56.31:9090 - Prometheus
- http://192.168.56.30:8080 - Spring Boot приложение

### 4. Проверка метрик

- Откройте: http://192.168.56.30:8080/actuator/prometheus
- Должны отображаться метрики приложения

## Отладка

Если что-то не работает, проверьте логи:

```bash
# Логи Spring Boot приложения
vagrant ssh app
sudo journalctl -u spring-boot-app -n 100

# Логи Prometheus
vagrant ssh monitoring
sudo journalctl -u prometheus -n 100

# Логи Grafana
vagrant ssh monitoring
sudo journalctl -u grafana-server -n 100
```

## Полезные команды для Windows

```bash
# Остановить VM
vagrant halt

# Перезапустить VM
vagrant reload

# Удалить VM
vagrant destroy -f

# Статус VM
vagrant status

# SSH подключение
vagrant ssh app
vagrant ssh monitoring
```

## Дополнительная помощь

Если проблемы сохраняются:

1. Убедитесь, что VirtualBox установлен и работает
2. Убедитесь, что виртуализация включена в BIOS
3. Проверьте, что достаточно места на диске (минимум 10GB)
4. Проверьте, что достаточно оперативной памяти (минимум 8GB)

## Рекомендации

Для наилучшего опыта работы с Lab 6 на Windows:

1. ✅ Используйте WSL2 с Ubuntu
2. ✅ Устанавливайте все инструменты внутри WSL
3. ✅ Храните проекты в файловой системе WSL (`~/projects/`) для лучшей производительности
4. ❌ Избегайте использования Git Bash для Ansible команд
5. ❌ Не используйте CMD для развертывания

## Контакты

Для получения дополнительной помощи обратитесь к документации:
- README.md - основная документация
- QUICK_START.md - быстрый старт
- STRUCTURE.md - описание структуры проекта
