DOCKER := docker
DOCKER_BUILD_FLAGS :=

SPACE=$() $()
COMMA=,

TAG ?= $(shell date +"%Y%m%d")
REPOSITORY := openvpn-ivpn

# Auto enable buildx when available
BUILDX_ENABLED := $(shell docker buildx version > /dev/null 2>&1 && printf true || printf false)
BUILDX_PLATFORMS := linux/amd64 linux/arm64

ifdef REPOSITORY_PREFIX
    override REPOSITORY := $(REPOSITORY_PREFIX)/$(REPOSITORY)
endif

ifeq ($(BUILDX_ENABLED),true)
		override DOCKER := $(DOCKER) buildx

		override DOCKER_BUILD_FLAGS += --platform $(subst $(SPACE),$(COMMA),$(BUILDX_PLATFORMS))
endif

$(info Docker buildx enabled: $(BUILDX_ENABLED))

.PHONY: image image-push

image:
	$(DOCKER) build . \
		$(DOCKER_BUILD_FLAGS) \
		--tag $(REPOSITORY):$(TAG) \
		--tag $(REPOSITORY):latest

image-push:
ifeq ($(BUILDX_ENABLED),true)
	$(MAKE) image DOCKER_BUILD_FLAGS+="--push"
else
	$(DOCKER) push $(REPOSITORY) --all-tags
endif
