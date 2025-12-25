# ВАЖНО: Инструкция по обновлению для исправления ошибки

## Проблема
Вы видите ошибку:
```
Failed to set permissions on the temporary files Ansible needs to create when becoming an unprivileged user
chown: changing ownership of '/var/tmp/ansible-tmp-.../AnsiballZ_git.py': Operation not permitted
```

## Причина
Вы используете **СТАРУЮ** версию кода. Последние исправления заменили модуль `git` на `shell` команды.

## Решение

### Шаг 1: Обновите код из репозитория
```bash
cd /path/to/infrasture-as-a-code/lab6
git fetch origin
git checkout copilot/setup-monitoring-for-applications
git pull origin copilot/setup-monitoring-for-applications
```

### Шаг 2: Проверьте, что у вас правильная версия
```bash
# Эта команда должна показать "shell:" а НЕ "git:"
grep -A 5 "Clone Spring Boot" roles/spring_boot_app/tasks/main.yml
```

Вы должны увидеть:
```yaml
- name: Clone Spring Boot application repository
  shell: |
    if [ -d ...
```

Если вы видите `git:` вместо `shell:`, значит код НЕ обновлен!

### Шаг 3: Запустите развертывание
```bash
ansible-playbook -i inventories/hosts.ini deploy.yml
```

## Проверка версии файла
Убедитесь, что ваш файл `roles/spring_boot_app/tasks/main.yml` содержит:
- Строку с `shell: |`
- Команды `git clone` и `git fetch` внутри shell блока
- НЕ содержит модуль `git:` для клонирования

## Если ошибка сохраняется после обновления

1. Проверьте, что вы в правильной директории:
   ```bash
   pwd  # Должно показать .../lab6
   ```

2. Проверьте, что используется правильный ansible.cfg:
   ```bash
   cat ansible.cfg | grep pipelining
   # Должно показать: pipelining = True
   ```

3. Проверьте коммит:
   ```bash
   git log --oneline -1
   # Должно показать коммит d0a80e6 или новее
   ```

## Контакты
Если после выполнения всех шагов ошибка сохраняется, укажите:
- Вывод `git log --oneline -1`
- Вывод `grep -A 5 "Clone Spring Boot" roles/spring_boot_app/tasks/main.yml`
