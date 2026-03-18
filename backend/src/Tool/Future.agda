-- A type that can be passed to C and used
-- to interrupt asynchronous calls
-- and to get their results.
-- Interruption happens via calling hs_try_putmvar
-- on the first MVar;
-- freeing the StablePtrs is possible
-- via hs_free_stable_ptr.
{-# OPTIONS --erasure #-}
module Tool.Future where

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

{-# FOREIGN AGDA2HS
import GHC.Base (MVar#, RealWorld, IO(..), deRefStablePtr#)
import GHC.Stable (StablePtr(..))
import Unsafe.Coerce ( unsafeCoerce )

-- as we only use these in a foreign pragma,
-- we have to import them by hand
import Control.Concurrent.MVar (putMVar, newEmptyMVar)
import GHC.Conc (forkIO, killThread)
import Foreign.Storable (peekElemOff)
import Foreign.StablePtr (deRefStablePtr)
import Foreign.C.Types
#-}

record Future (a : Set) : Set where
  no-eta-equality; pattern
  constructor MkFuture
  field
    interruptionMVar : MVar ⊤
    resultMVar : MVar a
open Future public
{-# COMPILE AGDA2HS Future #-}

postulate
  -- A Left is retured if interrupted.
  runAsync : IO a → IO (Future (Either String a))
{-# COMPILE AGDA2HS runAsync existing-class #-}
{-# FOREIGN AGDA2HS
-- Starts an asynchronous calculation
-- and returns a Future to it.
runAsync :: IO a -> IO (Future (Either String a))
runAsync action = do
  intMVar <- (newEmptyMVar :: IO (MVar ()))
  resMVar <- (newEmptyMVar :: IO (MVar (Either String a)))

  -- The thread doing the actual calculation.
  -- It also wakes up the watcher thread.
  calculationThreadId <- forkIO $ (putMVar resMVar =<< (Right <$> action)) >> putMVar intMVar ()

  -- The thread killing the calculation thread if woken up.
  watcherThreadId <- forkIO $ do
    -- this is activated if intMVar gets filled
    readMVar intMVar
    killThread calculationThreadId
    putMVar resMVar (Left "interrupted")

  return $ MkFuture intMVar resMVar
#-}

-- Creates StablePtrs
-- and writes them to a memory area
-- provided by a C caller.
-- Note: it is the C side's responsibility
-- to free the StablePtrs.
writeFutureC : Ptr (StablePtr PrimMVar) → Future a → IO ⊤
writeFutureC ptr (MkFuture intMVar resMVar) = do
  intMVarSPtr <- newStablePtrPrimMVar intMVar
  resMVarSPtr <- newStablePtr resMVar
  let convPtr = the (Ptr (StablePtr PrimMVar)) (castPtr ptr)
  poke convPtr intMVarSPtr
  pokeElemOff (castPtr convPtr) 1 resMVarSPtr
{-# COMPILE AGDA2HS writeFutureC #-}

-- Similar to runAsync, but
-- we write the Future into a location
-- given by the caller.
-- This makes it easier to create C exports
-- for actions.
-- Note: it is the responsibility of the C side
-- to free the StablePtrs.
runAsyncC : IO a -> Ptr (StablePtr PrimMVar) -> IO ⊤
runAsyncC action ptr = writeFutureC ptr =<< runAsync action
{-# COMPILE AGDA2HS runAsyncC #-}
runAsyncC1 : (a -> IO b) -> a -> Ptr (StablePtr PrimMVar) -> IO ⊤
runAsyncC1 action param = runAsyncC (action param)
{-# COMPILE AGDA2HS runAsyncC1 #-}
runAsyncC2 : (a -> b -> IO c) -> a -> b -> Ptr (StablePtr PrimMVar) -> IO ⊤
runAsyncC2 action param = runAsyncC1 (action param)
{-# COMPILE AGDA2HS runAsyncC2 #-}
runAsyncC3 : (a -> b -> c -> IO d) -> a -> b -> c -> Ptr (StablePtr PrimMVar) -> IO ⊤
runAsyncC3 action param = runAsyncC2 (action param)
{-# COMPILE AGDA2HS runAsyncC3 #-}

-- Reads the result from the Future,
-- waiting for it until it is ready.
-- Throws if the calculation has already been interrupted.
getFromFuture : Future a -> IO a
getFromFuture (MkFuture intMVar resMVar) = do
  isEmpty <- isEmptyMVar intMVar
  if isEmpty
    then readMVar resMVar
    else error {i = cheat} "Tried to read from interrupted future"
  where
    open import Tool.Cheat
{-# COMPILE AGDA2HS getFromFuture #-}

-- A variant of getFromFuture to call from C,
-- with a pointer pointing to a StablePtrised Future,
-- where the result is wrapped into an Either.
-- Does not free the pointers.
-- If interrupted, the result is undefined.
postulate
  getFromFutureC : ∀ {a : Set} -> Ptr (StablePtr PrimMVar) -> IO a
{-# COMPILE AGDA2HS getFromFutureC existing-class #-}
{-# FOREIGN AGDA2HS
getFromFutureC :: forall a. Ptr (StablePtr PrimMVar) -> IO a
getFromFutureC ptr = do
  -- we assume both StablePtrs are of the same size
  resMVarSPtr <- peekElemOff (castPtr ptr :: Ptr (StablePtr (MVar (Either String a)))) 1
  -- we catch the exception and return an illegal value
  -- in order to unblock a C++ thread waiting for the result
  result <- readMVar =<< deRefStablePtr resMVarSPtr
  case result of
    Right a -> return a
    _       -> return (unsafeCoerce () :: a)
#-}

-- Exported functions to call from C.
-- The pointer should point to a Future
-- stored on the C side.
-- Instantiations to be exported to C.
getCIntFromFutureC : Ptr (StablePtr PrimMVar) -> IO CInt
getCIntFromFutureC = getFromFutureC
{-# COMPILE AGDA2HS getCIntFromFutureC #-}
waitForVoidFutureC : Ptr (StablePtr PrimMVar) -> IO ⊤
waitForVoidFutureC = getFromFutureC
{-# COMPILE AGDA2HS waitForVoidFutureC #-}
-- Note: the pointer received might have to be freed on the C side;
-- especially if it is a C string.
getPtrFromFutureC : Ptr (StablePtr PrimMVar) -> IO (Ptr a)
getPtrFromFutureC = getFromFutureC
{-# COMPILE AGDA2HS getPtrFromFutureC #-}

-- Interrupts the calculation behind the Future.
-- Do not call this from C;
-- use hs_try_putmvar instead
-- (that frees intMVarPtr, too).
-- Returns False if it has already been interrupted
-- and True otherwise.
interruptFuture : Future a -> IO Bool
interruptFuture (MkFuture intMVar _) = tryPutMVar intMVar tt
{-# COMPILE AGDA2HS interruptFuture #-}

{-# FOREIGN AGDA2HS
foreign export ccall getCIntFromFutureC :: Ptr (StablePtr PrimMVar) -> IO CInt
foreign export ccall waitForVoidFutureC :: Ptr (StablePtr PrimMVar) -> IO ()
foreign export ccall getPtrFromFutureC :: Ptr (StablePtr PrimMVar) -> IO (Ptr a)
#-}
