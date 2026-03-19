#include <TinyHsFFI.h>
#if defined(__cplusplus)
extern "C" {
#endif

/**
 * Represents a Haskell Future in C:
 * one StablePtr points to the interruption MVar
 * and the other one to the result MVar.
 */
typedef HsStablePtr CFuture[2];

/**
 * Aborts the calculation
 * and also frees the pointers in the Future.
 */
extern void abortC(CFuture future);

/**
 * Frees the pointers in the Future.
 */
extern void freeC(CFuture future);

/**
 * Waits for the calculation behind the Future
 * and writes the result to the memory location
 * defined by the pointer.
 * If there is an exception instead of a result,
 * it leaves the memory unchanged
 * and returns 0;
 * on success, it returns 1.
 *
 * For waiting for calculations without a result,
 * see `waitC`.
 */
extern HsBool getC_Char(CFuture future, char* destination);
extern HsBool getC_Int(CFuture future, int* destination);
extern HsBool getC_Int8(CFuture future, int8_t* destination);
extern HsBool getC_Int16(CFuture future, int16_t* destination);
extern HsBool getC_Int32(CFuture future, int32_t* destination);
extern HsBool getC_Int64(CFuture future, int64_t* destination);
extern HsBool getC_Word(CFuture future, uint32_t* destination);
extern HsBool getC_Word8(CFuture future, uint8_t* destination);
extern HsBool getC_Word16(CFuture future, uint16_t* destination);
extern HsBool getC_Word32(CFuture future, uint32_t* destination);
extern HsBool getC_Word64(CFuture future, uint64_t* destination);
extern HsBool getC_Float(CFuture future, float* destination);
extern HsBool getC_Double(CFuture future, double* destination);
extern HsBool getC_Bool(CFuture future, int* destination);
extern HsBool getC_Ptr(CFuture future, void** destination);
extern HsBool getC_FunPtr(CFuture future, void (*destination)(void));
extern HsBool getC_StablePtr(CFuture future, HsStablePtr* destination);

/**
 * Waits for the calculation behind the Future.
 * If there is an exception instead of a result,
 * it returns 0;
 * on success, it returns 1.
 *
 * For also retrieving results from non-void Futures,
 * see `getC`.
 */
extern HsBool waitC(CFuture future);

#if defined(__cplusplus)
}
#endif

