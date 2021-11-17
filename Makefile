DOCKER := docker
DOCKER_BUILD_FLAGS :=

TAG ?= $(shell date +"%Y%m%d")
REPOSITORY := openvpn-ivpn

ifdef REPOSITORY_PREFIX
    override REPOSITORY := $(REPOSITORY_PREFIX)/$(REPOSITORY)
endif

.PHONY: image

image:
	$(DOCKER) build . \
	$(DOCKER_BUILD_FLAGS) \
		--tag $(REPOSITORY):$(TAG) \
		--tag $(REPOSITORY):latest
