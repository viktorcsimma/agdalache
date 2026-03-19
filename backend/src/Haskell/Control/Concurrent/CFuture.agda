-- A type that can be passed to C and used
-- to interrupt asynchronous calls
-- and to get their results.
-- Basically an Agda interface to the library cfuture-2.0.
{-# OPTIONS --erasure #-}
module Haskell.Control.Concurrent.Future where

{-# FOREIGN AGDA2HS {-# LANGUAGE ScopedTypeVariables, MagicHash, UnboxedTuples #-} #-}

open import Haskell.Prelude
open import Haskell.Prim using (the)
open import Haskell.Foreign.C.Types
open import Haskell.Foreign.Ptr
open import Haskell.Foreign.StablePtr
open import Haskell.Foreign.Storable
open import Haskell.Control.Concurrent.MVar

open import Tool.PropositionalEquality
open import Tool.Foreign
open import Haskell.GHC.Conc
open import Haskell.Control.Concurrent.MVar

-- | Gets translated to HsStablePtr* (i.e. void**) in C.
CFuturePtr : Set
CFuturePtr = Ptr (StablePtr PrimMVar)

-- | An object representing an asynchronous calculation.
-- Filling the first MVar activates a thread that aborts the calculation
-- and writes Nothing to the other MVar
-- (which would otherwise contain the result).
-- It is recommended not to manipulate the MVars directly,
-- but to use the functions in the library instead.
record Future (a : Set) : Set where
  constructor MkFuture; no-eta-equality
  field
    interruptionMVar : MVar ⊤        -- ^ For interruption: fill it to interrupt the calculation.
    resultMVar : (MVar (Maybe a))    -- ^ For the result: Nothing if it has been aborted, Just otherwise.

-- | Starts an asynchronous calculation
-- and returns a 'Future' to it.
-- This is quite complicated and uses a lot of Haskell builtins;
-- hence the postulate.
postulate
  forkFuture : IO a -> IO (Future a)

-- | Interrupts the calculation behind the 'Future'.
-- Do not call this from C;
-- use hs_try_putmvar instead
-- (that frees the first 'MVar', too).
-- Returns 'False' if it has already been interrupted
-- and 'True' otherwise.
abort : Future a -> IO Bool
abort (MkFuture intMVar _) = tryPutMVar intMVar tt

-- | Creates 'StablePtr's
-- and writes them to a memory area
-- provided by a C caller.
-- Use this in functions where the C frontend provides
-- a 'CFuturePtr' to write the future to.
--
-- Note: it is the responsibility of the C side
-- to free the 'StablePtr's.
writeFutureC : CFuturePtr -> Future a -> IO ⊤
writeFutureC ptr (MkFuture intMVar resMVar) = do
  intMVarSPtr <- newStablePtrPrimMVar intMVar
  resMVarSPtr <- newStablePtr resMVar
  let convPtr = the CFuturePtr (castPtr ptr)
  poke convPtr intMVarSPtr
  pokeElemOff (castPtr convPtr) 1 resMVarSPtr

-- | Similar to 'forkFuture', but
-- we write the 'Future' into a location
-- given by the caller.
-- This makes it easier to create C exports
-- for actions.
--
-- Use this in functions where the C frontend provides
-- a 'CFuturePtr' to write the future to.
--
-- Note: it is the responsibility of the C side
-- to free the 'StablePtr's.
forkFutureC : CFuturePtr -> IO a -> IO ⊤
forkFutureC ptr action = writeFutureC ptr =<< forkFuture action

-- | Reads the result from the 'Future'.
-- This is a blocking call,
-- waiting for the result (or the 'Nothing' signalling interruption)
-- until it is ready.
get : Future a -> IO (Maybe a)
get (MkFuture _ resMVar) = readMVar resMVar

-- | A helper function to 'getC' and 'waitC',
-- expecting a function which we are going to do with the result.
-- Not meant to be used directly.
getCHelper : CFuturePtr -> (a -> IO ()) -> IO Bool
getCHelper futurePtr doOnCompletion = do
  -- we assume both StablePtrs are of the same size,
  -- which should be in a sane world
  resMVarSPtr <- peekElemOff (castPtr futurePtr :: Ptr (StablePtr (MVar (Maybe a)))) 1
  result <- readMVar =<< deRefStablePtr resMVarSPtr
  case result of
        Just a  -> doOnCompletion a >> return True
        _       -> return False  -- we don't run 'doOnCompletion' in this case


-- | A variant of 'get' to call from C
-- which writes the result to the memory location
-- defined by the pointer.
-- If there is 'Nothing' instead of a result,
-- it writes nothing to the pointer
-- and returns 'False';
-- on success, it returns 'True'.
--
-- Note: do _not_ call this on a freed 'Future'
-- (the abortC function of the C side frees it).
getC : {{Storable a}} -> CFuturePtr -> Ptr a -> IO Bool
getC futurePtr destPtr = getCHelper futurePtr (poke destPtr)

-- | Only waits until the calculation gets finished;
-- then returns 'True' if it was successful and 'False' otherwise.
-- To be called from C.
-- Differs from 'getC' in that it ignores the result.
--
-- Note: do _not_ call this on a freed 'Future'
-- (the abortC function of the C side frees it).
waitC : CFuturePtr -> IO Bool
waitC futurePtr = getCHelper futurePtr $ const $ return ()
