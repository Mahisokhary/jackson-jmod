# im just repacking this library
# original creator of library is https://github.com/FasterXML
# and is licensed under https://www.apache.org/licenses/LICENSE-2.0 license
# Original project: https://github.com/FasterXML/jackson/
#
# also current project is licensed with https://www.gnu.org/licenses/gpl-3.0.en.html license


GROUP := com/fasterxml/jackson/core
ARTIFACTS := jackson-core jackson-databind jackson-annotations
VERSION := 2.18.5
MAVEN_REPO := https://repo1.maven.org/maven2

BUILD_DIR := build/$(VERSION)
JAR_DIR := $(BUILD_DIR)/jar
CLASS_DIR := $(BUILD_DIR)/class
JMOD_DIR := $(BUILD_DIR)/jmod
LEGAL_NOTICES_DIR := $(BUILD_DIR)/legal_notices

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
	test -f $@/module-info.class || cp $@/META-INF/versions/9/module-info.class $@/module-info.class
	rm -rf $@/META-INF

$(LEGAL_NOTICES_DIR): JACKSON_LICENSE LICENSE
	mkdir -p $@
	cp $^ $@

$(JMOD_DIR)/%.jmod: $(CLASS_DIR)/% $(LEGAL_NOTICES_DIR)
	mkdir -p $(@D)
	jmod create \
		--module-version $(VERSION) \
		--class-path $(CLASS_DIR)/$* \
		--legal-notices $(LEGAL_NOTICES_DIR) \
		$@
