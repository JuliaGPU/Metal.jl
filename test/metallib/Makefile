METAL := xcrun -sdk macosx metal
METALLIB := xcrun -sdk macosx metallib
MACOSX_VERSIONS := 11 12 13 14 15 26

SOURCES := $(wildcard *.metal)
METALLIBS := $(foreach ver,$(MACOSX_VERSIONS),$(SOURCES:.metal=.$(ver).metallib))

# libraries packaged by the standalone `metallib` tool instead of the compiler driver
STANDALONE_METALLIBS := kernel.standalone.metallib

.PHONY: all
all: $(METALLIBS) $(STANDALONE_METALLIBS)

.PHONY: clean
clean:
	$(RM) $(METALLIBS) $(STANDALONE_METALLIBS)

define METALLIB_RULE
%.${1}.metallib: %.metal
	$$(METAL) -mmacosx-version-min=${1} $$(shell head -n1 $$< | cut -c4-) -o $$@ $$<
endef
$(foreach ver,$(MACOSX_VERSIONS),$(eval $(call METALLIB_RULE,$(ver))))

%.standalone.metallib: %.metal
	$(METAL) -mmacosx-version-min=13 -c -o $*.air $<
	$(METALLIB) -o $@ $*.air
	$(RM) $*.air
