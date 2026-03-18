-- Adding Haskell's foreign C types
-- as postulates.
{-# OPTIONS --erasure #-}
module Haskell.Foreign.C.Types where

open import Haskell.Prim.Eq
open import Haskell.Prim.Ord
open import Haskell.Prim.Num

postulate
  CChar CSChar CUChar CShort CUShort CInt CUInt CLong CULong CPtrdiff CSize CWchar CSigAtomic CLLong CULLong CIntPtr CUIntPtr CIntMax CUIntMax CClock CTime CFloat CDouble CFile CFpos CJmpBuf : Set

  instance
    iEqCChar : Eq CChar
    iOrdCChar : Ord CChar
    iNumCChar : Num CChar

    iEqCSChar : Eq CSChar
    iOrdCSChar : Ord CSChar
    iNumCSChar : Num CSChar

    iEqCUChar : Eq CUChar
    iOrdCUChar : Ord CUChar
    iNumCUChar : Num CUChar

    iEqCShort : Eq CShort
    iOrdCShort : Ord CShort
    iNumCShort : Num CShort

    iEqCUShort : Eq CUShort
    iOrdCUShort : Ord CUShort
    iNumCUShort : Num CUShort

    iEqCInt : Eq CInt
    iOrdCInt : Ord CInt
    iNumCInt : Num CInt

    iEqCUInt : Eq CUInt
    iOrdCUInt : Ord CUInt
    iNumCUInt : Num CUInt

    iEqCLong : Eq CLong
    iOrdCLong : Ord CLong
    iNumCLong : Num CLong

    iEqCULong : Eq CULong
    iOrdULong : Ord CULong
    iNumCULong : Num CULong

    iEqCPtrdiff : Eq CPtrdiff
    iOrdCPtrdiff : Ord CPtrdiff
    iNumCPtrdiff : Num CPtrdiff

    iEqCSize : Eq CSize
    iOrdCSize : Ord CSize
    iNumCSize : Num CSize

    iEqCWchar : Eq CWchar
    iOrdCWchar : Ord CWchar
    iNumCWchar : Num CWchar

    iEqCSigAtomic : Eq CSigAtomic
    iOrdCSigAtomic : Ord CSigAtomic
    iNumCSigAtomic : Num CSigAtomic

    iEqCLLong : Eq CLLong
    iOrdCLLong : Ord CLLong
    iNumCLLong : Num CLLong

    iEqCULLong : Eq CULLong
    iOrdCULLong : Ord CULLong
    iNumCULLong : Num CULLong

    iEqCIntPtr : Eq CIntPtr
    iOrdCIntPtr : Ord CIntPtr
    iNumCIntPtr : Num CIntPtr

    iEqCUIntPtr : Eq CUIntPtr
    iOrdCUIntPtr : Ord CUIntPtr
    iNumCUIntPtr : Num CUIntPtr

    iEqCIntMax : Eq CIntMax
    iOrdCIntMax : Ord CIntMax
    iNumCIntMax : Num CIntMax

    iEqCUIntMax : Eq CUIntMax
    iOrdCUIntMax : Ord CUIntMax
    iNumCUIntMax : Num CUIntMax

    iEqCClock : Eq CClock
    iOrdCClock : Ord CClock
    iNumCClock : Num CClock

    iEqCTime : Eq CTime
    iOrdCTime : Ord CTime
    iNumCTime : Num CTime

    iEqCFloat : Eq CFloat
    iOrdCFloat : Ord CFloat
    iNumCFloat : Num CFloat

    iEqCDouble : Eq CDouble
    iOrdCDouble : Ord CDouble
    iNumCDouble : Num CDouble
