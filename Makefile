TF_CLI = $(shell which terraform)
TF_DOCS_CLI = $(shell which terraform-docs)

.PHONY: init
init:
	$(TF_CLI) init

.PHONY: init-upgrade
init-upgrade:
	$(TF_CLI) init -upgrade

.PHONY: fmt
fmt:
	$(TF_CLI) fmt ./

.PHONY: validate
validate:
	$(TF_CLI) validate

.PHONY: docs
docs:
	$(TF_DOCS_CLI) ./

.PHONY: plan
plan:
	$(TF_CLI) plan -out .plan

.PHONY: apply
apply:
	$(TF_CLI) apply .plan

# ci-destroy adds -auto-approve to the terraform destroy command.
# It also checks if we are running in a pipeline and if we are destroying the stage 'dev'.
.PHONY: destroy
destroy:
	# Increase destroy speed by ignoring all Kubernetes deployed resources, the cluster is going down anyway...
	@if [ -n "$$(terraform state list | grep -E 'helm_release|kubectl_manifest|kubernetes_job|kubernetes_secret|kubernetes_config_map|kubernetes_namespace|kubectl')" ]; then \
		$(TF_CLI) state rm $$(terraform state list | grep -E 'helm_release|kubectl_manifest|kubernetes_job|kubernetes_secret|kubernetes_config_map|kubernetes_namespace|kubectl'); \
	fi
	$(TF_CLI) destroy -auto-approve
