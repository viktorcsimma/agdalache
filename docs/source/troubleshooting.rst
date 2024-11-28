.. _troubleshooting:

***************
Troubleshooting
***************

Some common problems that may occur.

* *An inexplicable compilation error:* often, trying once again solves the problem. If not, clear build files before another try.
* *agda2hs runs successfully but GHC fails:* this means either a problem with a foreign pragma (have you had a typo or used an identifier not previously imported?), a missing import (check All.agda and the .cabal file, as well as the import list of individual modules), or some bug in agda2hs (which might be temporarily circumvented through a foreign pragma).
* *The frontend complains about missing symbols:* something was wrong with importing the backend's static library; have you downloaded the right Qt version (compatible with GHC)? Also, check the C headers exported from the backend.
