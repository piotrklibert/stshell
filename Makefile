PKGS_BASE := Sockets Sport Iconv Announcements
PKGS_DEBUG := ObjectDumper ProfileTools STTools


.PHONY: images
images: base.im debug.im


.PHONY: base.im
base.im:
	gst-load \
		--verbose \
		--rebuild-image \
		--image-file ./base.im \
		$(PKGS_BASE)


.PHONY: debug.im
debug.im:
	gst-load \
		--verbose \
		--rebuild-image \
		--image-file ./debug.im \
		$(PKGS_BASE) $(PKGS_DEBUG)


run:
	gst \
		--rebuild-image \
		--no-gc-message \
		./src/start.st \
		-a RELEASE


run-debug:
	gst \
		--verbose \
		--no-gc-message \
		--image ./debug.im \
		./src/start.st \
		-a DEBUG


local:
	gst -gc -I ./debug.im


connect:
	rlwrap telnet 192.168.1.124 8500
