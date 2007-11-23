# 
# makefile for BathyScaphe all frameworks.
#

PBXBUILD = /usr/bin/xcodebuild
BUILD_OPTION = -configuration Deployment
OGREKIT_BUILD_OPTIONS = -target 'OgreKit (without Find Panel)' -configuration Release
CLEAN_OPTIONS = -alltargets
BUILD_DIR = build

SGFOUNDATION_FRWK = SGFoundation
SGAPPKIT_FRWK = SGAppKit
COCOMONAR_FRWK = CocoMonar
OGREKIT_FRWK = OgreKit

.PHONY: SGFoundation  SGAppKit CocoMonar OgreKit

all: SGFoundation SGAppKit CocoMonar OgreKit
	
SGFoundation: 
	cd $(SGFOUNDATION_FRWK) && $(PBXBUILD) $(BUILD_OPTION)
	
SGAppKit: SGFoundation
	cd $(SGAPPKIT_FRWK) && $(PBXBUILD) $(BUILD_OPTION)

CocoMonar: SGFoundation
	cd $(COCOMONAR_FRWK) && $(PBXBUILD) $(BUILD_OPTION)

OgreKit:
	cd $(OGREKIT_FRWK) && $(PBXBUILD) $(OGREKIT_BUILD_OPTIONS)

clean: clean-SGFoundation clean-SGAppKit clean-CocoMonar clean-OgreKit

clean-SGFoundation: 
	cd $(SGFOUNDATION_FRWK) && $(PBXBUILD) $(CLEAN_OPTIONS) clean && rm -fr $(BUILD_DIR)
	
clean-SGAppKit:
	cd $(SGAPPKIT_FRWK) && $(PBXBUILD) $(CLEAN_OPTIONS) clean && rm -fr $(BUILD_DIR)

clean-CocoMonar:
	cd $(COCOMONAR_FRWK) && $(PBXBUILD) $(CLEAN_OPTIONS) clean && rm -fr $(BUILD_DIR)

clean-OgreKit:
	cd $(OGREKIT_FRWK) && $(PBXBUILD) $(CLEAN_OPTIONS)  -configuration Release clean && rm -fr $(BUILD_DIR)

