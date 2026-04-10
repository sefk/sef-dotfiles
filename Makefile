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
HOME                ?= $(shell echo $$HOME)
# LINK_TARGET_PREFIX := $(subst $(HOME),.,$(LINK_TARGET_PREFIX))

FILE_EXCLUDES          = README README.md Makefile %.swp .% %.ignore bin config osx_services brewlist claude oh-my-zsh ssh_rc
SECRETS_FILE           = bash_secret
OLD_FILES              = .vimrc.before .vimrc.after
SERVICES_DIR           = ~/Library/Services

# Dependencies that will end up with symlinks
# Relies on "sort" to also remove dups
FILES_TO_LINK          = $(sort $(filter-out $(FILE_EXCLUDES),$(wildcard *)) $(SECRETS_FILE))
FILE_LINKS             = $(addprefix $(HOME)/.,$(FILES_TO_LINK))
CONFIG_SUBDIRS_TO_LINK = $(sort $(wildcard config/*))
CONFIG_SUBDIR_LINKS    = $(addprefix ~/.,$(CONFIG_SUBDIRS_TO_LINK))
OMZ_THEMES_TO_LINK     = $(sort $(wildcard oh-my-zsh/custom/themes/*))
OMZ_THEME_LINKS        = $(addprefix ~/.,$(OMZ_THEMES_TO_LINK))
CLAUDE_FILES_TO_LINK   = $(sort $(wildcard claude/*))
CLAUDE_DEEP_LINKS      = $(patsubst claude/%,~/.claude/%,$(CLAUDE_FILES_TO_LINK))

all: ~/bin ~/.ssh/config ~/.ssh/rc $(FILE_LINKS) $(CONFIG_SUBDIR_LINKS) $(OMZ_THEME_LINKS) $(SERVICES_DIR) $(CLAUDE_DEEP_LINKS)

# For directories, test
# 1. if exists (-e), but not symlink (-h), halt (don't clobber!)
# 2. if exists, but symlink, OK to remove (point to different place)

# Put config rule first to match before the next rule which would also match,
# but not as specific
~/.config/%: config/%
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -e $@ ] && [ -h $@ ]; then rm -r $(RMFLAG) $@; fi
	if [ ! -e ~/.config ]; then mkdir ~/.config; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

# Static pattern only (avoids ~/.% matching deep paths like ~/.claude/CLAUDE.md and creating circular deps)
$(FILE_LINKS): $(HOME)/.%: %
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -e $@ ] && [ -h $@ ]; then rm -r $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

~/bin:
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -e $@ ] && [ -h $@ ]; then rm -r $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/bin $@

~/.oh-my-zsh/custom/themes/%: oh-my-zsh/custom/themes/%
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -e $@ ] && [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

~/.ssh/config:
	if [ -e $@ ]; then false; fi
	if [ ! -e ~/.ssh ]; then mkdir ~/.ssh; fi
	cp sshconfig $@

~/.ssh/rc: ssh_rc
	if [ ! -e ~/.ssh ]; then mkdir ~/.ssh; fi
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -e $@ ] && [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/ssh_rc $@
	
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

# Deep links for ~/.claude/: link each file directly to the claude/ subdir in the repo.
~/.claude/%: $(LINK_TARGET_PREFIX)/claude/%
	mkdir -p $(dir $@)
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -e $@ ] && [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $< $@

.PHONY: $(SERVICES_DIR)
