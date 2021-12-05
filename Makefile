DOCKER := docker
DOCKER_BUILD_FLAGS :=

_=$() $()
TAG ?= $(shell date +"%Y%m%d")
REPOSITORY := openvpn-ivpn

BUILDX_ENABLED := $(shell docker buildx &> /dev/null && printf true || printf false)
BUILDX_PLATFORMS := linux/amd64 linux/arm64

ifdef REPOSITORY_PREFIX
    override REPOSITORY := $(REPOSITORY_PREFIX)/$(REPOSITORY)
endif

ifeq ($(BUILDX_ENABLED),true)
		override DOCKER := $(DOCKER) buildx

		DOCKER_BUILD_FLAGS += --platform $(subst $(_),:,$(BUILDX_PLATFORMS))
endif

$(info Docker buildx enabled: $(BUILDX_ENABLED))

.PHONY: image

image:
	$(DOCKER) build . \
		$(DOCKER_BUILD_FLAGS) \
		--tag $(REPOSITORY):$(TAG) \
		--tag $(REPOSITORY):latest
