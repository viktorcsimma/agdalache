#include "Backend/Future.hpp"
#include "Future.h" // the Haskell stub

template<>
int Future<int>::haskellGet() noexcept {
    return getCIntFromFutureC(stablePtrs);
}
