
# 
# makefile for subprojects.

PBXBUILD = /usr/bin/xcodebuild
BUILD_OPTION = -configuration Deployment
BUILD_DIR = build

BWAGENT = BWAgent

.PHONY: BWAgent

all: BWAgent

BWAgent:
	cd $(BWAGENT) && $(PBXBUILD) $(BUILD_OPTION)


clean: clean-BWAgent

clean-BWAgent:
	cd $(BWAGENT) && $(PBXBUILD) clean && rm -fr $(BUILD_DIR)

