.. _getting-started:

***************
Getting started
***************

Installation
------------

.. highlight:: sh

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
* Run the appropriate installation script: ``sh install.sh`` on Linux and ``something with PowerShell`` on Windows. (For the latter, you might need to modify some security settings in order for this to work.)
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
