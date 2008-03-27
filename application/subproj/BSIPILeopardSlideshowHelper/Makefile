# 
# makefile for BSIPILeopardSlideshowHelper
#

PBXBUILD = /usr/bin/xcodebuild
BUILD_DIR = build

PLUGIN_PATH=build/Release/BSIPILeopardSlideshowHelper.plugin

DARWIN_VER = $(shell uname -r | sed -e 's/\..*//')
LEOPARD_OR_GREATER = $(shell if [ $(DARWIN_VER) -ge 9 ] ;then echo YES ;fi)
ifeq ($(LEOPARD_OR_GREATER), YES) 
	Target = Build_Plugin
else
	Target = Check_Plugin
endif

all:
	@echo you must specify target name.

clean:
	@echo you must specify target name.


BSIPILeopardSlideshowHelper:
	$(MAKE) $(Target)

clean-BSIPILeopardSlideshowHelper:
	$(MAKE) clean-$(Target)

Build_Plugin:
	$(PBXBUILD) -configuration Release

Check_Plugin:
	@if [ ! -d $(PLUGIN_PATH) ] ; then \
echo ; \
echo "/**********************************************/"; \
echo "/*****             CAUTION             ********/"; \
echo "/**********************************************/"; \
echo ; \
echo "You MUST get BSIPILeopardSlideshowHelper.plugin."; \
echo "Visit this site and download BSIPILeopardSlideshowHelper.plugin."; \
echo ; \
echo "http://sourceforge.jp/projects/bathyscaphe/files/"; \
echo ; \
echo "/**********************************************/"; \
echo ; \
exit 1; \
fi

clean-Build_Plugin:
	$(PBXBUILD) -alltargets clean
	rm -rf $(BUILD_DIR)

clean-Check_Plugin:
	@echo "do nothing"
