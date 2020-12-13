# Автоматизация при помощи Ansible в контейнере

https://www.golinuxcloud.com/ansible-architecture/

Под Windows ansible отсутствует, использую docker: microsoft/ansible  
Для вызова нужно передать рабочую директорию и кучу параметров (использовать python3, автоматически принять ssh fingerprint...)

*Проверочный запуск из Powershell*  
`$p=$(pwd).Path; docker run -it -v "${p}/.ssh:/root/.ssh" -v "${p}:/workdir" --workdir "/workdir" --rm microsoft/ansible:latest ansible --ssh-common-args='-o StrictHostKeyChecking=no' --version -e 'ansible_python_interpreter=/usr/bin/python3' -u ubuntu -i hosts all -m ping`  
> ansible 2.7.0  
>   config file = /workdir/ansible.cfg  
>   configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']  
>   ansible python module location = /usr/lib/python2.7/dist-packages/ansible  
>   executable location = /usr/bin/ansible  
> python version = 2.7.12 (default, Dec  4 2017, 14:50:18) [GCC 5.4.0 20160609]  

Указать версию python3 в ansible.cfg не получилось, пришлось разбить параметры по файлам:  
**ansible.cfg**  
>[defaults]  
>host_key_checking = False  

**hosts**  
>30.x.xx.xx  
>[all:vars]  
>ansible_python_interpreter=/usr/bin/python3  

Поскольку inventory мне не требуется, запускать буду с переменными (IP и hostname укажу прямо в командной строке). Но и версию python тогда тоже приходится.  
*Важно: при указании хоста вместо инвентори после него необходима запятая.*  
`$p=$(pwd).Path; docker run -it -v "${p}/.ssh:/root/.ssh" -v "${p}:/workdir" --workdir "/workdir" --rm microsoft/ansible:latest ansible-playbook --become -e "ansible_python_interpreter=/usr/bin/python3" -u ubuntu -i 18.156.114.157, --extra-vars "hostname=testaws" stdprep.yml`  
