# 
# makefile for BathyScaphe all products.
#

PROJECT_ROOT	= $(CURDIR)

APPLICATION_ROOT = $(PROJECT_ROOT)/application
SUBPROJECTS_ROOT = $(APPLICATION_ROOT)/subproj
FRAMEWORK_ROOT	= $(PROJECT_ROOT)/frameworks
IBPALLETE = $(PROJECT_ROOT)/IBPallete
BSIPILeopardSlideshowHelper_Plugin = $(SUBPROJECTS_ROOT)/BSIPILeopardSlideshowHelper


DARWIN_VER = $(shell uname -r | sed -e 's/\..*//')
ENABLE_MDI = $(shell if [ $(DARWIN_VER) -ge 8 ] ;then echo YES ;fi)
ifeq ($(ENABLE_MDI), YES) 
	MAKE_MDI = mdimporter
	MDI_DIR = $(PROJECT_ROOT)/metadataimporter/BathyScaphe
else
	MAKE_MDI = makemdidir
	DUMMY_MDI_DIR = $(PROJECT_ROOT)/metadataimporter/BathyScaphe/build/BathyScaphe.mdimporter
endif

.PHONY: frameworks ibpallete

all: bathyscaphe

clean: clean-components clean-bathyscaphe

bathyscaphe: components
	cd $(APPLICATION_ROOT) && $(MAKE) all

clean-bathyscaphe:
	cd $(APPLICATION_ROOT) && $(MAKE) clean


# make components
components: frameworks $(MAKE_MDI) BSIPILeopardSlideshowHelper

frameworks: 
	cd $(FRAMEWORK_ROOT) && $(MAKE) all

# subprojects: 
#	cd $(SUBPROJECTS_ROOT) && $(MAKE) all

mdimporter:
	cd $(MDI_DIR) && $(MAKE) all

makemdidir:
	mkdir -p $(DUMMY_MDI_DIR)

BSIPILeopardSlideshowHelper:
	cd $(BSIPILeopardSlideshowHelper_Plugin) && $(MAKE) $@


# cleaning compoments
clean-components: clean-frameworks clean-$(MAKE_MDI) clean-BSIPILeopardSlideshowHelper

clean-frameworks:
	cd $(FRAMEWORK_ROOT) && $(MAKE) clean

# clean-subprojects:
#	cd $(SUBPROJECTS_ROOT) && $(MAKE) clean

clean-mdimporter:
	cd $(MDI_DIR) && $(MAKE) clean

clean-makemdidir:
	rm -fr $(DUMMY_MDI_DIR)

clean-BSIPILeopardSlideshowHelper:
	cd $(BSIPILeopardSlideshowHelper_Plugin) && $(MAKE) $@

# make IBPalletes
ibpallete:
	cd $(IBPALLETE) && $(MAKE) all
clean-ibpallete:
	cd $(IBPALLETE) && $(MAKE) clean

