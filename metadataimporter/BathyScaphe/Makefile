# 
# makefile for MetaData Importer
#

PBXBUILD = /usr/bin/xcodebuild
BUILD_OPTION = -configuration Deployment
BUILD_DIR = build

all:
	$(PBXBUILD) $(BUILD_OPTION)

clean:
	$(PBXBUILD) -alltargets clean
	rm -rf $(BUILD_DIR)
