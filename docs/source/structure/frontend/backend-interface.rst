*****************
Backend interface
*****************

The SDK already includes some classes that help you interact with the backend from C++.

HsAppStateWrapper
-----------------

If you use a mutable AppState,
the HsAppStateWrapper class is probably the easiest and safest way
to manipulate it.
It wraps a StablePtr to the AppState
in an RAII way,
creating the pointer in the constructor
and freeing it in the destructor.

The main structure is pre-written for you,
you should simply extend it with your methods.
E.g. if you have a function ::

  HsStablePtr initAppInteger(void)

exported from the backend which creates an AppState and returns a StablePtr to it,
you can write the constructor like this::

  HsAppStateWrapper::HsAppStateWrapper(): appStatePtr(initAppInteger()) {}

Or, for something like ::

  int addValueC(HsStablePtr appStatePtr, int value)

, you can write this::

  int HsAppStateWrapper::addValue(int value) {return addValueC(appStatePtr, value);}

Asynchronous calls returning futures have a C type signature like ::

  void addValueAsyncC(HsStablePtr appStatePtr, int value, HsPtr futurePtr)

This (assuming the Future stands for a `Future CInt`) can be translated to something like ::

  Future<int> addValueAsync(int value) {
    return Future<int>([this, value](HsPtr futurePtr){addValueAsyncC(appStatePtr, value, futurePtr);});
  }

The destructor frees the StablePtr with `hs_free_stable_ptr`
(included in the GHC runtime);
this way, an expensive foreign call can be avoided.
But you can also extend the destructor
according to your needs.

Future
------

See the section on futures for more details.
