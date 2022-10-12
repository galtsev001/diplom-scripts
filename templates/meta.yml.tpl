#cloud-config
users:
  - default
  - name: user-data
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    ssh_import_id:
    lock_passwd: false
    ssh_authorized_keys:
      -  key-ssh