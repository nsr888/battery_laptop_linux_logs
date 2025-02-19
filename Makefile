ASCIIGRAPH = asciigraph
ASCIIGRAPH_DOCKER = docker run -i --rm ghcr.io/guptarohit/asciigraph

log:
	./log.sh

capacity_graph:
	@for d in $(shell ls -d BAT*/); do \
		echo $$d; \
		grep -roP '(?<=capacity\:).*(?=%)' $$d | sort \
			| cut -d: -f2 | tr -d ' ' | $(ASCIIGRAPH) -h 5 -sc "blue"; \
	done

capacity_text:
	@for d in $(shell ls -d BAT*/); do \
		echo $$d; \
		grep -r 'capacity:' $$d | sort ; \
	done
