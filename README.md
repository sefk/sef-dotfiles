My environment files, and a makefile to create links.

Make sure the links here are universal, not particular to the system.

Makefile will set up symlinks.  Automatically sets up links for all files / directories checked in here.  Files here should **not** begin with a leading dot, although the link to them well.  Has some special creation and cleanup logic to handle the file `bash_secret`.  That file isn't to be checked in, but should otherwise be treated as a link target.  

Restriction: since I do sloppy text munging to create the relative pathnames for links, the target for these links must be a subdirectory of the user's home.


