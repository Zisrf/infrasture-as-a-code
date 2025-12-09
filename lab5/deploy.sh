#!/bin/bash

echo "=== Déploiement PostgreSQL Lab 5 ==="

# Activer l'environnement virtuel
source ~/ansible_venv/bin/activate

# Variables communes
SSH_ARGS="-o StrictHostKeyChecking=no -o IdentitiesOnly=yes"
INVENTORY="inventories/production.yml"
USER="vagrant"

echo "1. Test de connexion aux VMs..."
ansible -i $INVENTORY all -m ping -u $USER -e "ansible_ssh_common_args='$SSH_ARGS'"

echo "2. Déploiement PostgreSQL..."
ansible-playbook -i $INVENTORY deploy_postgresql.yml -u $USER -e "ansible_ssh_common_args='$SSH_ARGS'"

echo "3. Vérification finale..."
ansible -i $INVENTORY db -m shell -u $USER -e "ansible_ssh_common_args='$SSH_ARGS'" -a "sudo -u postgres psql -d app_db -c 'SELECT version();'"

echo "=== Déploiement terminé ==="
