# 
# makefile for BathyScaphe all products.
#

PBXBUILD	= xcodebuild
BUILD_OPTION	= -buildstyle Deployment
BATHYSCAPHE	= -target bathyscaphe $(BUILD_OPTION)
BUILD_DIR	= build

PROJECT_ROOT	= $(CURDIR)

FRAMEWORK_ROOT	= frameworks
FRAMEWORK_DIRS	= $(FRAMEWORK_ROOT)/SGFoundation \
		  $(FRAMEWORK_ROOT)/SGAppKit \
		  $(FRAMEWORK_ROOT)/SGNetwork \
		  $(FRAMEWORK_ROOT)/CocoMonar \
		  $(FRAMEWORK_ROOT)/Keychain

COMPONENT_DIRS	= $(FRAMEWORK_DIRS) \
		  application/subproj/BWAgent

ALL_DIRS	= $(COMPONENT_DIRS) application

DARWIN_VER = $(shell uname -r | sed -e 's/\..*//')
ifeq ($(DARWIN_VER), 8)
	COMPONENT_DIRS := $(COMPONENT_DIRS) metadataimporter/BathyScaphe
else
	MAKE_MDI_DIR = makemdidir
	MDI_DIR = metadataimporter/BathyScaphe/build/BathyScaphe.mdimporter
endif


all: components
	cd $(PROJECT_ROOT)/application && \
	$(PBXBUILD) $(BATHYSCAPHE)

clean:
	for dir in $(ALL_DIRS); do \
		cd $(PROJECT_ROOT)/$$dir && \
		$(PBXBUILD) -alltargets clean && \
		rm -rf $(BUILD_DIR); \
	done

components: $(MAKE_MDI_DIR)
	for dir in $(COMPONENT_DIRS); do \
		cd $(PROJECT_ROOT)/$$dir && \
		$(PBXBUILD) $(BUILD_OPTION); \
	done

makemdidir:
	mkdir -p $(MDI_DIR)

