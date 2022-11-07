#!/usr/bin/env bash
# shellcheck disable=SC1090

python3 -m ansible playbook playbooks/create_ca_certificate.yaml --ask-vault-pass