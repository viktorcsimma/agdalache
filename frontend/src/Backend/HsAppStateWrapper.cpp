#include "Backend/HsAppStateWrapper.hpp"
#include "Acorn.h"

HsAppStateWrapper::HsAppStateWrapper(): appStatePtr(initAppInteger()) {}

HsAppStateWrapper::~HsAppStateWrapper() {
    hs_free_stable_ptr(appStatePtr);
}
