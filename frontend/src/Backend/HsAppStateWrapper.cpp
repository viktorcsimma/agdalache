#include "Backend/HsAppStateWrapper.hpp"
#include "Interaction.h"

HsAppStateWrapper::HsAppStateWrapper(): appStatePtr(initAppInteger()) {}

HsAppStateWrapper::~HsAppStateWrapper() {
    hs_free_stable_ptr(appStatePtr);
}
