METAL := xcrun -sdk macosx metal
MACOSX_VERSIONS := 11 12 13 14

SOURCES := $(wildcard *.metal)
METALLIBS := $(foreach ver,$(MACOSX_VERSIONS),$(SOURCES:.metal=.$(ver).metallib))

.PHONY: all
all: $(METALLIBS)

.PHONY: clean
clean:
	$(RM) $(METALLIBS)

define METALLIB_RULE
%.${1}.metallib: %.metal
	$$(METAL) -mmacosx-version-min=${1} $$(shell head -n1 $$< | cut -c4-) -o $$@ $$<
endef
$(foreach ver,$(MACOSX_VERSIONS),$(eval $(call METALLIB_RULE,$(ver))))
