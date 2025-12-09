GROUP := com/fasterxml/jackson/core
ARTIFACTS := jackson-core jackson-databind jackson-annotations
VERSION := 2.18.5
MAVEN_REPO := https://repo1.maven.org/maven2

BUILD_DIR := build/$(VERSION)
JAR_DIR := $(BUILD_DIR)/jar
CLASS_DIR := $(BUILD_DIR)/class
JMOD_DIR := $(BUILD_DIR)/jmod

.SECONDARY:

JMOD_TARGETS := $(patsubst %,$(JMOD_DIR)/%.jmod,$(ARTIFACTS))

.DEFAULT_GOAL := package
.PHONY: package
package: $(JMOD_TARGETS)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

$(JAR_DIR)/%.jar:
	mkdir -p $(@D)
	wget -O $@ $(MAVEN_REPO)/$(GROUP)/$*/$(VERSION)/$*-$(VERSION).jar

$(CLASS_DIR)/%: $(JAR_DIR)/%.jar
	mkdir -p $@
	unzip -d $@ $<

$(CLASS_DIR)/%/module-info.class: $(CLASS_DIR)/%
	test -f $@ || cp $</META-INF/versions/9/module-info.class $@

$(JMOD_DIR)/%.jmod: $(CLASS_DIR)/% $(CLASS_DIR)/%/module-info.class
	mkdir -p $(@D)
	jmod create \
		--module-version $(VERSION) \
		--class-path $(CLASS_DIR)/$* \
		$@
