# 
# makefile for BathyScaphe application
#

PBXBUILD = xcodebuild
BUILD_OPTION = -configuration Deployment
BUILD_DIR = build

all:
	$(PBXBUILD) -target bathyscaphe $(BUILD_OPTION)

clean:
	$(PBXBUILD) -alltargets clean
	rm -rf $(BUILD_DIR)
