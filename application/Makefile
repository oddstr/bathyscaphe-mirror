# 
# makefile for BathyScaphe application
#

PBXBUILD = /usr/bin/xcodebuild
BUILD_OPTION = -configuration Deployment
BUILD_DIR = build
 
BUILD_OPTION := -target "bs another story" $(BUILD_OPTION)

all:
	$(PBXBUILD) $(BUILD_OPTION)

clean:
	$(PBXBUILD) -alltargets clean
	rm -rf $(BUILD_DIR)
