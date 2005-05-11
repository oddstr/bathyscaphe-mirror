# 
# makefile for CocoMonar application
#

ROOT = ..

include $(ROOT)/config

v1:
	$(PBXBUILD) -target v1 $(BUILD_OPTION)

all:
	$(PBXBUILD) $(BUILD_OPTION)

clean:
	$(PBXBUILD) -alltargets clean
	rm -rf $(BUILD_DIR)
