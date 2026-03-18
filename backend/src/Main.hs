-- A main program for a simple interpreter.
-- This is needed to be written in Haskell;
-- otherwise, Cabal does not accept it.
module Main where

import Data.Char (isDigit)
import Data.IORef
import Data.List (isPrefixOf)
import Data.Text (unpack, strip, pack)
import System.IO
import Text.Read (readMaybe)

import AppState
import Interaction
import Tool.Future

-- Command keywords.
eXIT_KEYWORD :: String
eXIT_KEYWORD = "exit"

main :: IO ()
main = do
  putStrLn $ "Hello world! In the code, you can manipulate the app state in various ways.\n"
  appState <- (MkAppState <$> newIORef 0) -- replace 0 with the default(s) your internal variable(s)
  prompt appState

-- the second parameter is the precision to apply
prompt :: AppState Integer -> IO ()
prompt appState = do
  counter <- readIORef $ counterRef appState
  putStr $ "Current counter value: " ++ show counter ++ "\nHere, the user can give some prompt.\n> "
  hFlush stdout   -- so that it gets printed immediately
  command <- (unpack . strip . pack) <$> getLine
  if command == eXIT_KEYWORD
  then do {putStrLn "Bye."; return ()}
  else do
    putStr "Doing some calculations here.\n" -- insert your calculations here
    prompt appState
