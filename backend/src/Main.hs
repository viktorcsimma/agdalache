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
aDD_KEYWORD :: String
aDD_KEYWORD = "add"
iNCFOR_KEYWORD :: String
iNCFOR_KEYWORD = "incfor"
eXIT_KEYWORD :: String
eXIT_KEYWORD = "exit"

main :: IO ()
main = do
  putStrLn $ "Hello world! In the code, you can manipulate the app state in various ways.\n"
  appState <- (MkAppState <$> newIORef 0)
  prompt appState

-- the second parameter is the precision to apply
prompt :: AppState Integer -> IO ()
prompt appState = do
  counter <- readIORef $ counterRef appState
  putStr $ "counter: " ++ show counter ++ "> \nPress Enter for the next iteration, or type \"exit\" to exit.\n"
  hFlush stdout   -- so that it gets printed immediately
  command <- (unpack . strip . pack) <$> getLine
  if command == eXIT_KEYWORD
  then do {putStrLn "Bye."; return ()}
  else prompt appState
