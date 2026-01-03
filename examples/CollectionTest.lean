/-
Collection and Option tests demonstrating various assertions.
-/

import LeanTest

open LeanTest

/-- Example: List tests -/
def listTests : TestSuite :=
  (TestSuite.empty "List Tests")
  |>.addTest "list length" (do
      let list := [1, 2, 3, 4, 5]
      return assertEqual 5 list.length)
  |>.addTest "list is empty" (do
      let emptyList : List Nat := []
      return assertEmpty emptyList)
  |>.addTest "list contains element" (do
      let list := [1, 2, 3, 4, 5]
      return assertContains list 3)
  |>.addTest "list head" (do
      let list := [1, 2, 3]
      return assertEqual (some 1) list.head?)
  |>.addTest "list concatenation" (do
      return assertEqual [1, 2, 3, 4] ([1, 2] ++ [3, 4]))

/-- Example: Option tests -/
def optionTests : TestSuite :=
  (TestSuite.empty "Option Tests")
  |>.addTest "some value is present" (do
      let opt := some 42
      return assertSome opt)
  |>.addTest "none value is absent" (do
      let opt : Option Nat := none
      return assertNone opt)
  |>.addTest "option map" (do
      let opt := some 5
      return assertEqual (some 10) (opt.map (· * 2)))
  |>.addTest "option getD with some" (do
      let opt := some 100
      return assertEqual 100 (opt.getD 0))
  |>.addTest "option getD with none" (do
      let opt : Option Nat := none
      return assertEqual 42 (opt.getD 42))

/-- Example: Custom data structure tests -/
structure Point where
  x : Int
  y : Int
  deriving Repr, BEq

def pointTests : TestSuite :=
  (TestSuite.empty "Point Tests")
  |>.addTest "point creation" (do
      let p := Point.mk 3 4
      return assertEqual 3 p.x)
  |>.addTest "points are equal" (do
      let p1 := Point.mk 1 2
      let p2 := Point.mk 1 2
      return assertEqual p1 p2)
  |>.addTest "points are not equal" (do
      let p1 := Point.mk 1 2
      let p2 := Point.mk 3 4
      return assertNotEqual p1 p2)

/-- Main function to run all tests -/
def main : IO UInt32 := do
  runTestSuitesWithExitCode [
    listTests,
    optionTests,
    pointTests
  ]
