/-
Examples of tests with custom error messages and intentional failures.
-/

import LeanTest

open LeanTest

/-- Example: Tests with custom messages -/
def customMessageTests : TestSuite :=
  (TestSuite.empty "Custom Message Tests")
  |>.addTest "custom assertion message" (do
      return assert (5 > 3) "Five should be greater than three")
  |>.addTest "custom equality message" (do
      return assertEqual 10 (5 + 5) "Addition should equal 10")
  |>.addTest "custom inequality message" (do
      return assertNotEqual 5 10 "These numbers should be different")

/-- Example: Function testing -/
def double (x : Nat) : Nat := x * 2
def triple (x : Nat) : Nat := x * 3
def isEven (x : Nat) : Bool := x % 2 == 0

def functionTests : TestSuite :=
  (TestSuite.empty "Function Tests")
  |>.addTest "double function" (do
      return assertEqual 10 (double 5))
  |>.addTest "triple function" (do
      return assertEqual 15 (triple 5))
  |>.addTest "isEven with even number" (do
      return assertTrue (isEven 4))
  |>.addTest "isEven with odd number" (do
      return assertFalse (isEven 7))

/-- Example: Edge cases and boundary tests -/
def edgeCaseTests : TestSuite :=
  (TestSuite.empty "Edge Case Tests")
  |>.addTest "empty list is empty" (do
      let empty : List Nat := []
      return assertEmpty empty)
  |>.addTest "zero equals zero" (do
      return assertEqual 0 0)
  |>.addTest "string empty check" (do
      return assertEqual "" "")
  |>.addTest "large number calculation" (do
      return assertEqual 1000000 (1000 * 1000))

/-- Example: Demonstrating test failures (commented out by default) -/
def failingTests : TestSuite :=
  (TestSuite.empty "Failing Tests (Examples)")
  -- Uncomment these to see failures:
--   |>.addTest "this will fail - wrong sum" (do
--       return assertEqual 5 (2 + 2) "2 + 2 should equal 4, not 5")
--   |>.addTest "this will fail - false is not true" (do
--       return assertTrue false)
--   |>.addTest "this will fail - lists are different" (do
--       return assertEqual [1, 2, 3] [1, 2, 4])

/-- Main function to run all tests -/
def main : IO Unit := do
  runTestSuites [
    customMessageTests,
    functionTests,
    edgeCaseTests,
    failingTests  -- Uncomment to see test failures
  ]
