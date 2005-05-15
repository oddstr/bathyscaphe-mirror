# 
# makefile for CocoMonar all products.
#

ROOT = .

include $(ROOT)/config

app:
	(cd $(FRAMEWORK_DIR) && $(MAKE)) && cd ..
	(cd $(MDI_DIR) && $(MAKE)) && cd ../..
	(cd $(BWA_DIR) && $(MAKE)) && cd ../../..
	(cd $(APPLICATION_DIR) && $(MAKE) app) && cd ..

clean:
	(cd $(FRAMEWORK_DIR) && $(MAKE) clean) && cd ..
	(cd $(MDI_DIR) && $(MAKE) clean) && cd ../..
	(cd $(BWA_DIR) && $(MAKE) clean) && cd ../../..
	(cd $(APPLICATION_DIR) && $(MAKE) clean) && cd ..
