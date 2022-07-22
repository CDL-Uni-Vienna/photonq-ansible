#!/usr/bin/env bash
# shellcheck disable=SC1090

python3 -m ansible playbook playbooks/deploy.yml --ask-vault-pass
