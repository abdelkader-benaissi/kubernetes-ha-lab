SHELL := /usr/bin/env bash
.PHONY: validate plan deploy evidence
validate:
	terraform -chdir=terraform fmt -check -recursive
	terraform -chdir=terraform init -backend=false
	terraform -chdir=terraform validate
	ansible-playbook -i inventory/hosts.yml playbooks/site.yml --syntax-check
plan:
	terraform -chdir=terraform plan
deploy:
	test -f inventory/generated-hosts.yml
	ansible-playbook -i inventory/generated-hosts.yml playbooks/site.yml
evidence:
	./scripts/collect-evidence.sh
