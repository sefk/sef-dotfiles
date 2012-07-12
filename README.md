** My environment files **

Now using submodules for vim plugins, so remember to do a "submodule init" and "submodule update" before doing anything else.

My pile of environment files. 

Makefile will set up symlinks.  Automatically sets up links for all files / directories checked in here.  Files here should **not** begin with a leading dot, although the link to them well.  Has some special creation and cleanup logic to handle the file `bash_secret`.  That file isn't to be checked in, but should otherwise be treated as a link target.  

Restriction: since I do sloppy text munging to create the relative pathnames for links, the target for these links must be a subdirectory of the user's home.

`git-completion.bash` just copied in here out of laziness.  Using version 1.7.11-rc0 from `http://repo.or.cz/w/git.git/blob/HEAD:/contrib/completion/git-completion.bash`.  I should probably use a submodule or something.


TODO
- Maybe all this gitconfig stuff shouldn't be universal?  Hm.
- Consider adding submodule stuff to the makefile.  That somehow seems wrong though.
