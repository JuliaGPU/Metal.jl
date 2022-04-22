METAL=metal
METAL_FLAGS=
.PHONY: all
all: vadd.metallib

vadd.air: vadd.metal
	${METAL} -c -o $@ $<

vadd.metallib: vadd.air
	${METAL} -o $@ $<

.PHONY: clean
clean:
	${RM} vadd.air vadd.metallib
