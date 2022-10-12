#Создание переменных для подключения к VM
key=$( cat ~/.ssh/id_rsa.pub )
#Используем шаблон meta.yml для terraform и преобразуем его согласно нашим переменным
cp ./templates/meta.yml.tpl meta.yml
sed -i "s|user-data|$USER|g" meta.yml
sed -i "s|key-ssh|$key|g" meta.yml
#Запуск установки инфраструктуры
terraform init
terraform apply -auto-approve
#вывод ip нашей инфраструктуры
terraform output > ./temp/output_data.txt
sed -i "s|galtsev|$USER|g" ./temp/output_data.txt
#Если kuberspray не скачен и не лежит в корне папки с main.tf то клонируем его
 [ ! -d "./kuberspray" ] && git clone https://github.com/kubernetes-sigs/kubespray.git && pip3 install -r ./kubespray/requirements.txt
 [ ! -d "./inventory" ] && mkdir inventory 
 cp -r ./kubespray/inventory/sample/* ./inventory
 #преобразование выходных файлов в инвентори для ansible
python3 ./scripts/convert_inventory_file.py
#Чтобы нас не мучало с постоянным вводом пароля ключа
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
export ANSIBLE_HOST_KEY_CHECKING=False
#Запуск сценария ожидания готовности серверов
ansible-playbook -i ./inventory/inventory.yaml --become wait.yml
#Настроим кластер для удаленного подключения (получим ip control panel и добавим его в переменные kuberspray)
ansible-playbook -i ./inventory/inventory.yaml --become get_ip.yml #Генерация строчки ex. => supplementary_addresses_in_ssl_keys: [178.154.224.87]
sleep 5
cat remote_access.txt >> ./inventory/group_vars/k8s_cluster/k8s-cluster.yml
#Установка Kubernets
# ansible-playbook -i ./inventory/inventory.yaml  ./kubespray/cluster.yml -b -v
ansible-playbook -i ./inventory/inventory.yaml create-kube-config.yml 