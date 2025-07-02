
.PHONY: dev
dev:
	packer build -var-file=./config/develop.pkrvars.hcl ./

.PHONY: qa
qa:
	packer build -var-file=./config/qa.pkrvars.hcl ./

.PHONY: prod
prod:
	packer build -var-file=./config/prod.pkrvars.hcl ./