# 
# makefile for BathyScaphe all frameworks.
#

PBXBUILD = /usr/bin/xcodebuild
BUILD_OPTION = -configuration Deployment
BUILD_DIR = build

SGFOUNDATION_FRWK = SGFoundation
SGAPPKIT_FRWK = SGAppKit
SGNETWORK_FRWK = SGNetwork
COCOMONAR_FRWK = CocoMonar
KEYCHAIN_FRWK = Keychain

.PHONY: SGFoundation  SGAppKit SGNetwork CocoMonar Keychain

all: SGFoundation SGAppKit SGNetwork CocoMonar
	
SGFoundation: 
	cd $(SGFOUNDATION_FRWK) && $(PBXBUILD) $(BUILD_OPTION)
	
SGAppKit: SGFoundation
	cd $(SGAPPKIT_FRWK) && $(PBXBUILD) $(BUILD_OPTION)

SGNetwork: SGFoundation
	cd $(SGNETWORK_FRWK) && $(PBXBUILD) $(BUILD_OPTION) 

CocoMonar: SGFoundation
	cd $(COCOMONAR_FRWK) && $(PBXBUILD) $(BUILD_OPTION)

Keychain:
	cd $(KEYCHAIN_FRWK) && $(PBXBUILD) $(BUILD_OPTION)

clean: clean-SGFoundation clean-SGAppKit clean-SGNetwork clean-CocoMonar

clean-SGFoundation: 
	cd $(SGFOUNDATION_FRWK) && $(PBXBUILD) clean && rm -fr $(BUILD_DIR)
	
clean-SGAppKit:
	cd $(SGAPPKIT_FRWK) && $(PBXBUILD) clean && rm -fr $(BUILD_DIR)

clean-SGNetwork:
	cd $(SGNETWORK_FRWK) && $(PBXBUILD) clean && rm -fr $(BUILD_DIR)

clean-CocoMonar:
	cd $(COCOMONAR_FRWK) && $(PBXBUILD) clean && rm -fr $(BUILD_DIR)

clean-Keychain:
	cd $(KEYCHAIN_FRWK) && $(PBXBUILD) clean && rm -fr $(BUILD_DIR)

