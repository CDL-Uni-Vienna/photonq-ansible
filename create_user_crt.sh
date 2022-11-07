#!/usr/bin/env bash
# shellcheck disable=SC1090

python3 -m ansible playbook playbooks/create_user_certificate.yaml --ask-vault-pass