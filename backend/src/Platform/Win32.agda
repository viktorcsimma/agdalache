-- Implementation of platform-specific functions
-- for Windows.

module Platform.Win32 where

{-# FOREIGN AGDA2HS {-# LANGUAGE ScopedTypeVariables #-} #-}

{-# FOREIGN AGDA2HS

import Control.Concurrent
import System.Win32.Console.CtrlHandler
import System.Win32.Event
import System.Win32.Process (sleep)
import System.Win32.File (closeHandle)
import System.Win32.Types (HANDLE, BOOL)
import Foreign.C.Types (CInt)

-- It will be CInt so that it can be easily got as a parameter.
type SemName = CInt

-- Opens a new thread which is going to write its result into an MVar.
-- Also opens a "watcher thread"
-- which is going to wait on an event
-- (with a name generated from the SemName parameter)
-- and if it is triggered, stops the calculation
-- and writes a Nothing into the MVar.
-- If the calculation runs successfully (so with Just sth),
-- the watcher thread is stopped by triggering the event;
-- if there is already a result in the MVar,
-- it does nothing.
-- The event is created by the watcher thread itself;
-- the "outer world" only needs to open it.
runInterruptibly :: SemName -> IO a -> IO a -> IO a
runInterruptibly tid action resultOnInterrupt = do
  (mVar :: MVar (Maybe a)) <- newEmptyMVar
  childThreadId <- forkIO (putMVar mVar =<< (Just <$> action))

  let eventName = show tid

  -- We create the event here so that
  -- we can be sure it exists
  -- and can be accessed by both threads
  -- (otherwise, the thread creating it could be slower
  -- then the other one trying to access it).
  -- But the handle will be closed by the watcher thread
  -- as it will use it at last.
  -- This is an auto-reset event.
  eventHandle <- createEvent Nothing False False eventName

  watcherThreadId <- forkIO $ do
    waitResult <- threadWaitForSingleObject eventHandle
    if waitResult == wAIT_OBJECT_0
      then do
        -- this will do nothing if the MVar has already been filled
        wasEmpty <- tryPutMVar mVar Nothing
        closeHandle eventHandle
        if wasEmpty
        then killThread childThreadId
        else return ()
      else do
        closeHandle eventHandle
        error "waitResult failed"

  -- we can restrict a handler to a certain call
  maybeResult <- withConsoleCtrlHandler
                     (interruptControlHandler eventHandle)
                     (readMVar mVar)
  -- we only readMVar, so that it remains full
  -- and the watcher thread knows if there has been a result

  case maybeResult of
    Just result -> do
      -- stop the watcher thread by triggering the event
      setEvent eventHandle
      return result
    -- in this case, the watcher thread has already run
    -- and stopped the calculation thread
    Nothing -> resultOnInterrupt


-- Poll the event until it gets signalled.
-- Unlike waitForSingleObject, this will block only the current thread
-- rather than the entire process.
-- Used System.Posix.Semaphore for inspiration.
threadWaitForSingleObject :: HANDLE -> IO WaitResult
threadWaitForSingleObject handle = do res <- waitForSingleObject handle 0 -- this returns immediately
                                      if wAIT_TIMEOUT == res then do { yield; threadWaitForSingleObject handle }
                                      else return res

-- A handler which signals a given event for Control-C.
interruptControlHandler :: HANDLE -> CtrlEvent -> IO BOOL
interruptControlHandler eventHandle ctrlEvent
  | cTRL_C_EVENT == ctrlEvent    = setEvent eventHandle >> return True
  | otherwise                    = return False

#-}
