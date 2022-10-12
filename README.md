#### Скрипт установки инфраструктуры и kubernetes

* [Инструкция по запуску](#инструкция-по-запуску)
* [Описание файлов](#описание-файлов)
* [Схема работы скрипта](#схема-работы-скрипта)
* [Планы на будущее или что можно было бы сделать лучше](#планы-на-будущее-или-что-можно-было-бы-сделать-лучше)

---

##### Инструкция по запуску

*Необходимые инструменты для работы*

+ Terraform
+ Ansible
+ Python

*Генерация ssh-ключа*

По умолчанию скрипт берет ssh-ключ для работы из домашней директории `~/.ssh/id_rsa.pub`. Если его нет, то можно сгенерировать (либо пересоздать):

```bash
ssh-keygen -t rsa
```
Далее следовать инструкции (имя оставить по умолчанию).

*Установка прав на исполнение*

После копирования файлов скрипта нужно установить тип файла как "запускаемый" для `run.sh`

```bash
sudo chmod +x run.sh
```

*Запуск скрипта*

```bash
./run.sh 
```

##### Описание файлов

##### Схема работы скрипта

##### Планы на будущее или что можно было бы сделать лучше

+ Файл `main.tf` заточен под мои учетные данные. Наверное было бы лучше научить скрипт запрашивать их у пользователя при старте. Либо проверять конфиг файл с этими данными. Если их нет, то прекращать работу.

+ Все инструкции для `ansible` "упаковать в роли" и объединить в единый файл

+ Автоматическую генерацию ssh-ключа в начале работы скрипта