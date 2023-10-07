# Simple makefile to install a bunch of symlinks for my environment files
# The files aren't preceeded by a dot in the source tree, but they are in
# the target.
#
# "bash_secret" is not intended to be checked in (on purpose) for things
# that aren't intended for general knowledge.  So we need to explicitly
# add it to the list of sources (since it isn't checked in) and then create
# it if its not present.
#

SHELL := /bin/bash
RMFLAG =   # if you want warnings, add -i here

LINK_TARGET_PREFIX := $(shell pwd)
LINK_TARGET_PREFIX := $(subst $(HOME),.,$(LINK_TARGET_PREFIX))

EXCLUDES      = README README.md Makefile %.swp .% %.ignore bin osx_services brewlist iterm_prefs
SECRETS_FILE  = bash_secret
OLD_FILES     = .vimrc.before .vimrc.after
FILES_TO_LINK = $(sort $(filter-out $(EXCLUDES),$(wildcard *)) $(SECRETS_FILE))		# sort also removes dups
LINKS         = $(addprefix ~/.,$(FILES_TO_LINK))
SERVICES_DIR  = ~/Library/Services

all: ~/bin ~/.ssh/config $(LINKS) $(SERVICES_DIR)

# first test: if exists (-e), but not symlink (-h), halt (don't clobber!)
# second test: if exists, but symlink, OK to remove (point to different place)
~/.%: %
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -e $@ ] && [ -h $@ ]; then rm -r $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

~/bin:
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -e $@ ] && [ -h $@ ]; then rm -r $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/bin $@

~/.ssh/config:
	if [ -e $@ ]; then false; fi
	if [ ! -e ~/.ssh ]; then mkdir ~/.ssh; fi
	cp sshconfig $@
	
$(SECRETS_FILE):
	if [ ! -e $(SECRETS_FILE) ]; then touch $(SECRETS_FILE); fi

# only remove secrets file if it exists but is empty, i.e. likely that this makefile
# created it
clean:
	-rm -r $(RMFLAG) $(LINKS)
	-rm -r $(RMFLAG) $(OLD_FILES)
	if [ -e $(SECRETS_FILE) ] && [ ! -s $(SECRETS_FILE) ]; then rm $(RMFLAG) $(SECRETS_FILE); fi

$(SERVICES_DIR):
	if [ $(shell uname) == Darwin ]; then \
		rsync -rupEv osx_services/ $(SERVICES_DIR); \
	fi

.PHONY: $(SERVICES_DIR)
