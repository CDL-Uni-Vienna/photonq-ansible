#!/usr/bin/env bash
# shellcheck disable=SC1090

python3 -m ansible playbook playbooks/status_detailed.yml --ask-vault-pass