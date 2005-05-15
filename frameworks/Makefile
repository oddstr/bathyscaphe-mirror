# 
# makefile for CocoMonar all frameworks.
#

ROOT = ..

include $(ROOT)/config

subsystem:
	(cd $(SGFOUNDATION_FRWK) && $(MAKE)) && cd ..
	(cd $(SGAPPKIT_FRWK) && $(MAKE)) && cd ..
	(cd $(SGNETWORK_FRWK) && $(MAKE)) && cd ..
	(cd $(COCOMONAR_FRWK) && $(MAKE)) && cd ..
	(cd $(KEYCHAIN_FRWK) && $(MAKE)) && cd ..
	
clean:
	(cd $(SGFOUNDATION_FRWK) && $(MAKE) clean) && cd ..
	(cd $(SGAPPKIT_FRWK) && $(MAKE) clean) && cd ..
	(cd $(SGNETWORK_FRWK) && $(MAKE) clean) && cd ..
	(cd $(COCOMONAR_FRWK) && $(MAKE) clean) && cd ..
	(cd $(KEYCHAIN_FRWK) && $(MAKE) clean) && cd ..
