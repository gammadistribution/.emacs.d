.emacs.d/
========

Repository for my .emacs file. File stored in .emacs.d/init.el.


Being that you would clone this repository using git, you have already
satisfied one half of the requirements, the other half being emacs v23 and an
internet connection.  All you have to do is clone this repository into your
home directory (~/) and run emacs.  The initialization file (init.el) will do
all of the lispy magic if the folder is cloned into a user's home directory.
Specifically, it will fetch el-get and install it under the repo .emacs.d and
then fetch all of the additional packages maintained by el-get as well as load
all of the cool customizations.

You may need to restart emacs if you receive a git clone error as it has
trouble loading it all in one go.  This is only the start-up cost and won't
need to be done each time once all dependencies have been downloaded.

If you want to use the python syntax checkers (pep8 and pyflakes) you need to
install those via pip and chmod +x ~/.emacs.d/bin/pycheckers
