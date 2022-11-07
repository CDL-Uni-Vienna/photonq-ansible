#!/usr/bin/env bash
# shellcheck disable=SC1090

python3 -m ansible playbook playbooks/un_deploy.yml --ask-vault-pass
