METAL := xcrun -sdk macosx metal
METALLIB := xcrun -sdk macosx metallib
MACOSX_VERSIONS := 11 12 13 14 15 26

# sources that need a dedicated rule (see below)
SPECIAL_SOURCES := dependencies.metal dependencies_helper.metal coreimage.metal dylib.metal imports.metal

SOURCES := $(filter-out $(SPECIAL_SOURCES),$(wildcard *.metal))
METALLIBS := $(foreach ver,$(MACOSX_VERSIONS),$(SOURCES:.metal=.$(ver).metallib))

# libraries packaged by the standalone `metallib` tool instead of the compiler driver
STANDALONE_METALLIBS := kernel.standalone.metallib dependencies.standalone.metallib

SPECIAL_METALLIBS := coreimage.metallib dylib.metallib imports.metallib kernels.compressed.metallib

.PHONY: all
all: $(METALLIBS) $(STANDALONE_METALLIBS) $(SPECIAL_METALLIBS)

.PHONY: clean
clean:
	$(RM) $(METALLIBS) $(STANDALONE_METALLIBS) $(SPECIAL_METALLIBS)

define METALLIB_RULE
%.${1}.metallib: %.metal
	$$(METAL) -mmacosx-version-min=${1} $$(shell head -n1 $$< | cut -c4-) -o $$@ $$<
endef
$(foreach ver,$(MACOSX_VERSIONS),$(eval $(call METALLIB_RULE,$(ver))))

%.standalone.metallib: %.metal
	$(METAL) -mmacosx-version-min=13 -c -o $*.air $<
	$(METALLIB) -o $@ $*.air
	$(RM) $*.air

dependencies.standalone.metallib: dependencies.metal dependencies_helper.metal
	$(METAL) -mmacosx-version-min=13 -c -o dependencies.air dependencies.metal
	$(METAL) -mmacosx-version-min=13 -c -o dependencies_helper.air dependencies_helper.metal
	$(METALLIB) --function-dependencies -o $@ dependencies.air dependencies_helper.air
	$(RM) dependencies.air dependencies_helper.air

coreimage.metallib: coreimage.metal
	$(METAL) -mmacosx-version-min=13 -fcikernel -c -o coreimage.air $<
	$(METALLIB) --cikernel -o $@ coreimage.air
	$(RM) coreimage.air

dylib.metallib: dylib.metal
	$(METAL) -mmacosx-version-min=13 -dynamiclib -install_name @loader_path/$@ -o $@ $<

imports.metallib: imports.metal dylib.metallib
	$(METAL) -mmacosx-version-min=13 -o $@ $^

# compressed modules and reflection need metallib v1.2.9 (macOS 26)
kernels.compressed.metallib: kernels.metal
	$(METAL) -mmacosx-version-min=26 -Xlinker --compress-sections -o $@ $<
