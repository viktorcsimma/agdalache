#ifndef HS_APP_STATE_WRAPPER_HPP_
#define HS_APP_STATE_WRAPPER_HPP_

#include "TinyHsFFI.h"

/**
 * A wrapper class containing
 * a pointer to a Haskell AppState object
 * and handling it in a RAII way.
 */
class HsAppStateWrapper {
  private:

    // A pointer to the Haskell AppState object;
    // this is what will be passed to Haskell functions.
    const HsStablePtr appStatePtr;

  public:
    // The constructor.
    // This also creates the Haskell object and fetches its pointer.
    // Beware: it assumes that the runtime has already been initalised.
    HsAppStateWrapper();

    // You can write your methods here.

    // The destructor.
    // This also runs interruptEvaluation() and frees the StablePtr
    // but does not shut down the runtime.
    ~HsAppStateWrapper();

    // We delete the copy constructor and the assignment operator.
    HsAppStateWrapper(const HsAppStateWrapper& temp_obj) = delete; 
    HsAppStateWrapper& operator=(const HsAppStateWrapper& temp_obj) = delete; 
};

#endif
