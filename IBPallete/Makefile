# 
# makefile for BathyScaphe all IBPallete.
#

PBXBUILD = /usr/bin/xcodebuild
BUILD_OPTION = -configuration Deployment -target All
BUILD_DIR = build

BSDATEPICKER_IBPALLET = BSDatePicker

.PHONY: BSDatePicker

all: BSDatePicker
	
BSDatePicker:
	cd $(BSDATEPICKER_IBPALLET) && $(PBXBUILD) $(BUILD_OPTION)

clean: clean-BSDatePicker

clean-BSDatePicker:
	cd $(BSDATEPICKER_IBPALLET) && $(PBXBUILD) clean && rm -fr $(BUILD_DIR)

