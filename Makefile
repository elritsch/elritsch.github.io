JEKYLL_DOCKER_IMG = jekyll/jekyll:3.4
LOCAL_JEKYLL_PORT = 4000

all: jekyll-docker

jekyll-docker:
	docker run -ti --volume $(PWD):/srv/jekyll --publish $(LOCAL_JEKYLL_PORT):4000 $(JEKYLL_DOCKER_IMG) jekyll serve

.PHONY: jekyll-docker
