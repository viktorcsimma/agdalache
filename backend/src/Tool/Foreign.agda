-- Contains some functions and foreign types useful
-- when writing the functions
-- to be exported to C.
{-# OPTIONS --erasure #-}

module Tool.Foreign where
{-# FOREIGN AGDA2HS
import qualified Platform
import qualified Foreign.C.String
import Foreign.C.Types
#-}

open import Haskell.Prelude
open import Haskell.Foreign.C.Types
open import Haskell.Foreign.Ptr
open import Haskell.Foreign.StablePtr

-- For C types.
postulate
  unsafeIntegerToCInt : Integer → CInt
  unsafeIntToCInt : Int → CInt
  cIntToInteger : CInt → Integer
  cIntToInt : CInt → Int

{-# COMPILE AGDA2HS unsafeIntegerToCInt existing-class #-}
{-# COMPILE AGDA2HS unsafeIntToCInt existing-class #-}
{-# COMPILE AGDA2HS cIntToInteger existing-class #-}
{-# COMPILE AGDA2HS cIntToInt existing-class #-}

{-# FOREIGN AGDA2HS
unsafeIntegerToCInt :: Integer -> CInt
unsafeIntegerToCInt = fromIntegral

unsafeIntToCInt :: Int -> CInt
unsafeIntToCInt = fromIntegral

cIntToInteger :: CInt -> Integer
cIntToInteger = fromIntegral

cIntToInt :: CInt -> Int
cIntToInt = fromIntegral
#-}

CString : Set
CString = Ptr CChar
postulate
  newCString : String → IO CString
{-# FOREIGN AGDA2HS
type CString = Foreign.C.String.CString

newCString :: String -> IO CString
newCString = Foreign.C.String.newCString
#-}

SemName : Set
SemName = CInt

postulate
  -- Runs an action interruptible
  -- through a named semaphore (on Posix)
  -- or a named event (on Windows).
  -- SemName identifies the semaphore/event,
  -- the first IO is the lengthy evaluation,
  -- the second is a default to be returned if interrupted.
  runInterruptibly : SemName -> IO a -> IO a -> IO a

{-# FOREIGN AGDA2HS

type SemName = Platform.SemName

runInterruptibly :: SemName -> IO a -> IO a -> IO a
runInterruptibly = Platform.runInterruptibly
#-}

-- Functions that reduce the amount of boilerplate code
-- by making Haskell functions
-- accept a StablePtr instead of an AppState,
-- thereby making them callable from C.
stablePtrise : {a b : Set} -> (a -> IO b) -> (StablePtr a -> IO b)
stablePtrise f sptr = deRefStablePtr sptr >>= f
{-# COMPILE AGDA2HS stablePtrise #-}
stablePtrise2 : {a b c : Set} -> (a -> b -> IO c)
                                -> (StablePtr a -> b -> IO c)
stablePtrise2 f sptr b = deRefStablePtr sptr >>= λ appState → f appState b
{-# COMPILE AGDA2HS stablePtrise2 #-}
stablePtrise3 : {a b c d : Set} -> (a -> b -> c -> IO d)
                                -> (StablePtr a -> b -> c -> IO d)
stablePtrise3 f sptr b c = deRefStablePtr sptr >>= λ appState → f appState b c
{-# COMPILE AGDA2HS stablePtrise3 #-}
