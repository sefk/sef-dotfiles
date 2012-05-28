# Simple makefile to install a bunch of symlinks for my environment files
# The files aren't preceeded by a dot in the source tree, but they are in
# the target.
#
# "bash_secret" is not intended to be checked in (on purpose) for things 
# that aren't intended for general knowledge.  So we need to explicitly
# add it to the list of sources (since it isn't checked in) and then create
# it if its not present.
#
# Copyright Sef Kloninger 2012, all rights reserved
#

SHELL := /bin/bash

# RMFLAG = -i   # if you want warnings
RMFLAG = 

TARGET_LOC = ~
EXCLUDES = README Makefile %.swp .% %.ignore

SECRETS_FILE = bash_secret

SOURCES = $(filter-out $(EXCLUDES),$(wildcard *)) SECRETS_FILE
TARGETS = $(addprefix $(TARGET_LOC)/.,$(SOURCES))

all: $(TARGETS)

$(TARGET_LOC)/.%: %
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi              # exists, not symlink, stop (don't clobber!)
	if [ -e $@ ] && [ -h $@ ]; then rm -r $(RMFLAG) $@; fi   # exists, symlink, remove
	ln -s ~/src/sef-dotfiles/$< $@                           # create symlink

$(SECRETS_FILE): 
	if [ ! -e $(SECRETS_FILE) ]; then touch $(SECRETS_FILE); fi

# only remove secrets file if it exists but is empty (ie. likely that this makefile
# created it
clean:
	-rm -r -i $(TARGETS)
	if [ -e $(SECRETS_FILE) ] && [ ! -s $(SECRETS_FILE)]; then rm $(RMFLAG) $(SECRETS_FILE); fi

