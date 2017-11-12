JEKYLL_DOCKER_IMG = jekyll/jekyll:latest
LOCAL_JEKYLL_PORT = 4000

all: jekyll-docker

jekyll-docker:
	docker run -ti --volume $(PWD):/srv/jekyll --publish $(LOCAL_JEKYLL_PORT):4000 $(JEKYLL_DOCKER_IMG) jekyll serve

.PHONY: jekyll-docker
