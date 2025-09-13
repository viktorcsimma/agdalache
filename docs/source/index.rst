.. _index:

************************
Welcome to the Agdalache documentation!
************************

Agdalache is a project intended to help developers
utilising Agda-powered, provably correct backends
in C++ Qt applications
using the *agda2hs* compiler.

It consists of:

* installation scripts for fetching all the necessary tools from the Internet;
* a project template to get you started in no time;
* several pre-made frameworks to help you interact with the backend from C++ (e.g. Haskell futures);
* this documentation.

In order to utilise the SDK, a basic understanding of Agda and agda2hs is needed,
as well as an intermediate proficiency in Haskell
(i.e. knowing the IO monad and being able to navigate the documentation).
However, frontend developers can join the C++ part of your project,
even with no knowledge of Agda at all!

Check out the chapter :ref:`getting-started` to install the SDK
and :ref:`structure` for more details.
Or alternatively, see an `example project <https://github.com/viktorcsimma/skeleton/tree/even-counter>`_
to get an idea
(it is about manipulating a counter that can provably contain only even values).

.. toctree::
   :maxdepth: 3

   getting-started
   structure/index
   compilation
   troubleshooting
   contributions
