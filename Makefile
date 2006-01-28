# 
# makefile for BathyScaphe all products.
#

PROJECT_ROOT	= $(CURDIR)

APPLICATION_ROOT = $(PROJECT_ROOT)/application
SUBPROJECTS_ROOT = $(APPLICATION_ROOT)/subproj
FRAMEWORK_ROOT	= $(PROJECT_ROOT)/frameworks

DARWIN_VER = $(shell uname -r | sed -e 's/\..*//')
ENABLE_MDI = $(shell if [ $(DARWIN_VER) -ge 8 ] ;then echo YES ;fi)
ifeq ($(ENABLE_MDI), YES) 
	MAKE_MDI = mdimporter
	MDI_DIR = $(PROJECT_ROOT)/metadataimporter/BathyScaphe
else
	MAKE_MDI = makemdidir
	DUMMY_MDI_DIR = $(PROJECT_ROOT)/metadataimporter/BathyScaphe/build/BathyScaphe.mdimporter
endif

.PHONY: frameworks

all: bathyscaphe

clean: clean-components clean-bathyscaphe

bathyscaphe: components
	cd $(APPLICATION_ROOT) && $(MAKE) all

clean-bathyscaphe:
	cd $(APPLICATION_ROOT) && $(MAKE) clean


# make components
components: frameworks subprojects $(MAKE_MDI)

frameworks: 
	cd $(FRAMEWORK_ROOT) && $(MAKE) all

subprojects: 
	cd $(SUBPROJECTS_ROOT) && $(MAKE) all

mdimporter:
	cd $(MDI_DIR) && $(MAKE) all

makemdidir:
	mkdir -p $(DUMMY_MDI_DIR)

# cleaning compoments
clean-components: clean-frameworks clean-subprojects clean-$(MAKE_MDI)

clean-frameworks:
	cd $(FRAMEWORK_ROOT) && $(MAKE) clean

clean-subprojects:
	cd $(SUBPROJECTS_ROOT) && $(MAKE) clean

clean-mdimporter:
	cd $(MDI_DIR) && $(MAKE) clean

clean-makemdidir:
	rm -fr $(DUMMY_MDI_DIR)

