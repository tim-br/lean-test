/-
Basic test examples demonstrating assertion usage.
-/

import LeanTest

open LeanTest

/-- Example: Basic arithmetic tests -/
def arithmeticTests : TestSuite :=
  (TestSuite.empty "Arithmetic Tests")
  |>.addTest "addition works correctly" (do
      return assertEqual 4 (2 + 2))
  |>.addTest "subtraction works correctly" (do
      return assertEqual 0 (5 - 5))
  |>.addTest "multiplication works correctly" (do
      return assertEqual 20 (4 * 5))
  |>.addTest "division works correctly" (do
      return assertEqual 3 (9 / 3 : Nat))

/-- Example: Boolean assertion tests -/
def booleanTests : TestSuite :=
  (TestSuite.empty "Boolean Tests")
  |>.addTest "assert true condition" (do
      return assertTrue true)
  |>.addTest "assert false condition" (do
      return assertFalse false)
  |>.addTest "refute false condition" (do
      return refute false)
  |>.addTest "equality check" (do
      return assertEqual true true)

/-- Example: String tests -/
def stringTests : TestSuite :=
  (TestSuite.empty "String Tests")
  |>.addTest "string concatenation" (do
      return assertEqual "hello world" ("hello" ++ " " ++ "world"))
  |>.addTest "strings are not equal" (do
      return assertNotEqual "foo" "bar")
  |>.addTest "string length check" (do
      let str := "test"
      return assertEqual 4 str.length)

/-- Main function to run all tests -/
def main : IO UInt32 := do
  runTestSuitesWithExitCode [
    arithmeticTests,
    booleanTests,
    stringTests
  ]
