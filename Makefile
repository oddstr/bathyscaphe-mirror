# 
# makefile for CocoMonar all products.
#

ROOT = .

include $(ROOT)/config

v1:
	(cd $(FRAMEWORK_DIR) && $(MAKE)) && cd ..
	(cd $(APPLICATION_DIR) && $(MAKE) v1) && cd ..

all:
	(cd $(FRAMEWORK_DIR) && $(MAKE)) && cd ..
	(cd $(APPLICATION_DIR) && $(MAKE)) && cd ..

clean:
	(cd $(FRAMEWORK_DIR) && $(MAKE) clean) && cd ..
	(cd $(APPLICATION_DIR) && $(MAKE) clean) && cd ..
