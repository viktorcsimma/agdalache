#include "Backend/Future.hpp"
#include <CFuture.h>

template<>
int Future<int>::haskellGet() noexcept {
    int result;
    bool success = getC_Int(stablePtrs, &result);
    if (success) return result;
    else return -1; // silent failure -- see the header
}
