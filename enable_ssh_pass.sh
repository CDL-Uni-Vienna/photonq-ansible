#!/usr/bin/env bash
# shellcheck disable=SC1090

python3 -m ansible playbook playbooks/enable_ssh_pass.yml --ask-vault-pass