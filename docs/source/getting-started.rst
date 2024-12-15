.. _getting-started:

***************
Getting started
***************

.. highlight:: sh

Installation
------------

Via apt
^^^^^^^

The Agda SDK is available as an ``apt`` repo! For installing from there, issue these commands::

  echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/csimmaviktor.gpg] http://fwc.horcsin.hu:8888/ unstable main' | sudo tee /etc/apt/sources.list.d/agdasdk.list
  curl -fsSL https://csimmaviktor.web.elte.hu/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/csimmaviktor.gpg
  sudo apt update
  sudo apt install agdasdk

Afterwards, you should add the agda2hs library to your ``AGDA_LIB/libraries`` file (see details `here <(https://agda.readthedocs.io/en/v2.6.4.3/tools/package-system.html>`_). So, for Linux::

  mkdir -p ~/.config/agda
  echo "/usr/share/x86_64-linux-ghc-9.4.8/Agda-2.6.4.3/lib/prim/agda-builtins.agda-lib
  /usr/share/agda2hs/agda2hs.agda-lib" | tee -a ~/.config/agda/libraries

For configuring Emacs, you don't need to install an Agda instance; simply copy this to your ``.emacs`` file::

  (load-file (let ((coding-system-for-read 'utf-8))
                  (shell-command-to-string "agda-mode locate")))
  (custom-set-variables
   '(agda2-program-name "agda2hs")
  )

  (require 'package)
  (package-initialize)


Via the installation scripts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The installation scripts can be found in the repo itself
(which you will probably want to use).
These scripts download all the necessary tools
directly from their producers.
This means:

* GHC;
* agda2hs (a `custom version <https://github.com/viktorcsimma/agda2hs/tree/the-agda-sdk>`_ -- the vanilla compiler will probably not work);
* Qt (a version that is compatible with the machine code produced by GHC).

So, to install this kit, do the following:

* Clone the repository (of course, you need Git for this) by saying::

    git clone https://github.com/viktorcsimma/skeleton

Or you can also fork the repo on GitHub and work on your fork from then on.
* Switch to the root of the repo with ``cd``.
* Run the appropriate installation script: ``sh install.sh`` on Linux or the PowerShell script on Windows. (For the latter, you might need to modify some security settings in order for this to work.)
And you are now set and done!

Alternatively, you can also download the tools yourself. In this case, make sure you have

* the custom agda2hs fork available on the `the-agda-sdk <https://github.com/viktorcsimma/agda2hs/tree/the-agda-sdk>`_ branch of github.com/viktorcsimma/agda2hs;
* a Qt version compatible with GHC-generated libraries (that is, ``linux_gcc_64`` on Linux and ``win64_llvm_mingw`` on Windows).

First project
-------------

To start, simply use the skeleton repo cloned in the previous step (you can change the origin, fork the repository, or create a new one, if you wish).

You may, however, want to change the project name
from the ugly and simple *"skeleton"*
to a more appealing one.
To do so, follow the steps in `this commit diff <https://github.com/viktorcsimma/skeleton/commit/23c65f83fa1965789319c90eab42503ab4a06661>`_.

An automatised script for doing this would be welcome!
