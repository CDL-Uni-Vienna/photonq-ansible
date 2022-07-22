#!/usr/bin/env bash
# shellcheck disable=SC1090

python3 -m ansible playbook playbooks/status.yml --ask-vault-pass