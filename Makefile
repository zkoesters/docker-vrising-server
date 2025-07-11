REPO_NAME  ?= zkoesters
IMAGE_NAME ?= vrising-server

DOCKER=docker
GIT=git

OFFIMG_LOCAL_CLONE=$(HOME)/official-images
OFFIMG_REPO_URL=https://github.com/docker-library/official-images.git

all: build test

build:
	$(DOCKER) build -t $(REPO_NAME)/$(IMAGE_NAME):latest -f Dockerfile .
	$(DOCKER) images   $(REPO_NAME)/$(IMAGE_NAME):latest

test-prepare:
ifeq ("$(wildcard $(OFFIMG_LOCAL_CLONE))","")
	$(GIT) clone $(OFFIMG_REPO_URL) $(OFFIMG_LOCAL_CLONE)
endif

test: test-prepare build
	$(OFFIMG_LOCAL_CLONE)/test/run.sh -c $(OFFIMG_LOCAL_CLONE)/test/config.sh $(REPO_NAME)/$(IMAGE_NAME):latest

.PHONY: build test-prepare test all