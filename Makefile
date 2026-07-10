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

FILE_EXCLUDES          = README README.md CLAUDE.md AGENTS.md Makefile %.swp .% %.ignore bin config osx_services brewlist claude oh-my-zsh ssh_rc launchd sshconfig docs pi herdr codex
SECRETS_FILE           = bash_secret
OLD_FILES              = .vimrc.before .vimrc.after
SERVICES_DIR           = ~/Library/Services
LAUNCHD_AGENTS_TO_LINK = $(sort $(wildcard launchd/*.plist))
LAUNCHD_AGENT_LINKS    = $(patsubst launchd/%,~/Library/LaunchAgents/%,$(LAUNCHD_AGENTS_TO_LINK))

# Dependencies that will end up with symlinks
# Relies on "sort" to also remove dups
FILES_TO_LINK          = $(sort $(filter-out $(FILE_EXCLUDES),$(wildcard *)) $(SECRETS_FILE))
FILE_LINKS             = $(addprefix $(HOME)/.,$(FILES_TO_LINK))
CONFIG_SUBDIRS_TO_LINK = $(sort $(wildcard config/*))
CONFIG_SUBDIR_LINKS    = $(addprefix ~/.,$(CONFIG_SUBDIRS_TO_LINK))
OMZ_THEMES_TO_LINK     = $(sort $(wildcard oh-my-zsh/custom/themes/*))
OMZ_THEME_LINKS        = $(addprefix ~/.,$(OMZ_THEMES_TO_LINK))
OMZ_COMPLETIONS_TO_LINK = $(sort $(wildcard oh-my-zsh/custom/completions/*))
OMZ_COMPLETION_LINKS    = $(addprefix ~/.,$(OMZ_COMPLETIONS_TO_LINK))
CLAUDE_FILES_TO_LINK   = $(sort $(wildcard claude/*))
CLAUDE_DEEP_LINKS      = $(patsubst claude/%,~/.claude/%,$(CLAUDE_FILES_TO_LINK))
PI_FILES_TO_LINK       = $(sort $(wildcard pi/*))
PI_DEEP_LINKS          = $(patsubst pi/%,~/.pi/agent/%,$(PI_FILES_TO_LINK))
HERDR_FILES_TO_LINK    = $(sort $(wildcard herdr/*))
HERDR_DEEP_LINKS       = $(patsubst herdr/%,~/.config/herdr/%,$(HERDR_FILES_TO_LINK))
CODEX_FILES_TO_LINK    = $(sort $(wildcard codex/*))
CODEX_DEEP_LINKS       = $(patsubst codex/%,~/.codex/%,$(CODEX_FILES_TO_LINK))

all: ~/bin ~/.ssh/config ~/.ssh/rc $(FILE_LINKS) $(CONFIG_SUBDIR_LINKS) $(OMZ_THEME_LINKS) $(OMZ_COMPLETION_LINKS) $(SERVICES_DIR) $(CLAUDE_DEEP_LINKS) $(PI_DEEP_LINKS) $(HERDR_DEEP_LINKS) $(CODEX_DEEP_LINKS) $(LAUNCHD_AGENT_LINKS)

# For directories, test
# 1. if exists (-e), but not symlink (-h), halt (don't clobber!)
# 2. if exists, but symlink, OK to remove (point to different place)

# Put config rule first to match before the next rule which would also match,
# but not as specific
~/.config/%: config/%
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	if [ ! -e ~/.config ]; then mkdir ~/.config; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

# Static pattern only (avoids ~/.% matching deep paths like ~/.claude/CLAUDE.md and creating circular deps)
$(FILE_LINKS): $(HOME)/.%: %
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

~/bin:
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/bin $@

~/.oh-my-zsh/custom/themes/%: oh-my-zsh/custom/themes/%
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

# zsh completions (omz adds custom/completions to fpath). After adding a new
# one, refresh the compdump: rm -f ~/.zcompdump* && exec zsh
~/.oh-my-zsh/custom/completions/%: oh-my-zsh/custom/completions/%
	mkdir -p $(dir $@)
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

~/.ssh/config:
	if [ -e $@ ]; then false; fi
	if [ ! -e ~/.ssh ]; then mkdir ~/.ssh; fi
	cp sshconfig $@

~/.ssh/rc: ssh_rc
	if [ ! -e ~/.ssh ]; then mkdir ~/.ssh; fi
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/ssh_rc $@
	
$(SECRETS_FILE):
	if [ ! -e $(SECRETS_FILE) ]; then touch $(SECRETS_FILE); fi

# only remove secrets file if it exists but is empty, i.e. likely that this makefile
# created it
# Plain rm (no -r): every target here is a symlink; if one is somehow a real
# directory, failing beats recursively deleting its contents.
clean:
	-rm $(RMFLAG) $(FILE_LINKS) $(CONFIG_SUBDIR_LINKS) $(OMZ_THEME_LINKS) $(OMZ_COMPLETION_LINKS) $(CLAUDE_DEEP_LINKS) $(PI_DEEP_LINKS) $(HERDR_DEEP_LINKS) $(CODEX_DEEP_LINKS) $(LAUNCHD_AGENT_LINKS) ~/bin
	-rm $(RMFLAG) $(addprefix $(HOME)/,$(OLD_FILES))
	if [ -e $(SECRETS_FILE) ] && [ ! -s $(SECRETS_FILE) ]; then rm $(RMFLAG) $(SECRETS_FILE); fi

$(SERVICES_DIR):
	if [ $(shell uname) == Darwin ]; then \
		rsync -rupEv osx_services/ $(SERVICES_DIR); \
	fi

# launchd user agents: symlink each plist into ~/Library/LaunchAgents/.
# After linking a new one, load it: launchctl bootstrap gui/$(id -u) <plist>
~/Library/LaunchAgents/%: launchd/%
	mkdir -p $(dir $@)
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $(LINK_TARGET_PREFIX)/$< $@

# Deep links for ~/.claude/: link each file directly to the claude/ subdir in the repo.
~/.claude/%: $(LINK_TARGET_PREFIX)/claude/%
	mkdir -p $(dir $@)
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $< $@

# Deep links for ~/.pi/agent/: link each file directly to the pi/ subdir in the repo.
# Excludes auth.json (secrets), bin/ (vendored fd/rg), npm/ (extension package
# state), sessions/ (transcripts) -- none of those are checked in.
~/.pi/agent/%: $(LINK_TARGET_PREFIX)/pi/%
	mkdir -p $(dir $@)
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $< $@

# Deep links for ~/.config/herdr/: link each file directly to the herdr/ subdir
# in the repo. Only config.toml is checked in -- the sockets, logs, session.json,
# and agent-detection state that herdr writes into this dir are runtime state and
# stay out of the repo. File-level linking (not a whole-dir symlink) keeps them out.
~/.config/herdr/%: $(LINK_TARGET_PREFIX)/herdr/%
	mkdir -p $(dir $@)
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $< $@

# Deep links for ~/.codex/: link each checked-in codex file into place. Only
# hand-authored config is tracked -- AGENTS.md, hooks.json, and the herdr
# integration hook. codex/AGENTS.md is itself a symlink to the shared
# config/agents/GLOBAL.md (codex can't @import like Claude does, so it reads the
# shared instructions through the link). NOT config.toml (codex rewrites it at runtime
# with machine-specific trust entries, marketplace hashes, and absolute app
# paths), auth.json (secrets), or the sqlite DBs / sessions/ / plugins/ / cache/
# that also live under ~/.codex. File-level linking keeps all that out of the repo.
~/.codex/%: $(LINK_TARGET_PREFIX)/codex/%
	mkdir -p $(dir $@)
	if [ -e $@ ] && [ ! -h $@ ]; then false; fi
	if [ -h $@ ]; then rm $(RMFLAG) $@; fi
	ln -s $< $@

.PHONY: $(SERVICES_DIR)
