/-
Tests for advanced assertions: assertInRange, assertError, assertOk, assertThrows, assertSucceeds
-/

import LeanTest

open LeanTest

/-- Tests for assertInRange -/
def rangeTests : TestSuite :=
  (TestSuite.empty "Range Assertions")
  |>.addTest "value in range - integers" (do
      return assertInRange 5 1 10)
  |>.addTest "value at lower bound" (do
      return assertInRange 1 1 10)
  |>.addTest "value at upper bound" (do
      return assertInRange 10 1 10)
  |>.addTest "value in range - floats" (do
      return assertInRange 5.5 1.0 10.0)
  |>.addTest "single value range" (do
      return assertInRange 42 42 42)
  |>.addTest "negative range" (do
      return assertInRange (-5) (-10) 0)
  |>.addTest "value outside range fails" (do
      let result := assertInRange 15 1 10
      match result with
      | .failure _ => return assert true
      | .success => return assert false "Expected failure for value outside range")

/-- Tests for Except assertions -/
def exceptTests : TestSuite :=
  (TestSuite.empty "Except Assertions")
  |>.addTest "assertError detects error" (do
      let result : Except String Nat := .error "something went wrong"
      return assertError result)
  |>.addTest "assertError fails on ok" (do
      let result : Except String Nat := .ok 42
      let assertion := assertError result
      match assertion with
      | .failure _ => return assert true
      | .success => return assert false "Expected failure for ok value")
  |>.addTest "assertOk detects ok" (do
      let result : Except String Nat := .ok 42
      return assertOk result)
  |>.addTest "assertOk fails on error" (do
      let result : Except String Nat := .error "failed"
      let assertion := assertOk result
      match assertion with
      | .failure _ => return assert true
      | .success => return assert false "Expected failure for error value")

/-- Helper function that divides, returning Except -/
def safeDivide (x y : Nat) : Except String Nat :=
  if y = 0 then
    .error "division by zero"
  else
    .ok (x / y)

/-- Tests for Except with real operations -/
def exceptOperationTests : TestSuite :=
  (TestSuite.empty "Except Operations")
  |>.addTest "division succeeds" (do
      return assertOk (safeDivide 10 2))
  |>.addTest "division by zero fails" (do
      return assertError (safeDivide 10 0))
  |>.addTest "division result is correct" (do
      match safeDivide 10 2 with
      | .ok val => return assertEqual 5 val
      | .error _ => return assert false "Division should have succeeded")

/-- Helper IO functions for testing -/
def successfulIO : IO Unit := do
  pure ()

def failingIO : IO Unit := do
  throw (IO.userError "intentional error")

def readNonexistentFile : IO String := do
  IO.FS.readFile "/this/file/does/not/exist/hopefully.txt"

/-- Tests for IO assertions -/
def ioTests : TestSuite :=
  (TestSuite.empty "IO Assertions")
  |>.addTest "assertSucceeds with successful IO" (do
      assertSucceeds successfulIO)
  |>.addTest "assertThrows with failing IO" (do
      assertThrows failingIO)
  |>.addTest "assertThrows with nonexistent file" (do
      assertThrows readNonexistentFile)
  |>.addTest "assertSucceeds fails with throwing IO" (do
      let result ← assertSucceeds failingIO
      match result with
      | .failure _ => return assert true
      | .success => return assert false "Expected failure for throwing IO")
  |>.addTest "assertThrows fails with successful IO" (do
      let result ← assertThrows successfulIO
      match result with
      | .failure _ => return assert true
      | .success => return assert false "Expected failure for successful IO")

/-- Tests with custom messages -/
def customMessageTests : TestSuite :=
  (TestSuite.empty "Advanced Assertions with Custom Messages")
  |>.addTest "assertInRange with custom message" (do
      return assertInRange 5 0 10 "Age should be between 0 and 10")
  |>.addTest "assertError with custom message" (do
      let result : Except String Nat := .error "oops"
      return assertError result "Expected an error from the operation")
  |>.addTest "assertOk with custom message" (do
      let result : Except String Nat := .ok 100
      return assertOk result "Operation should have succeeded")
  |>.addTest "assertThrows with custom message" (do
      assertThrows readNonexistentFile "File read should fail")

/-- Complex scenario: validating parsed input -/
structure Config where
  port : Nat
  timeout : Nat
  deriving Repr

def parseConfig (port : Nat) (timeout : Nat) : Except String Config :=
  if port < 1024 then
    .error "port must be >= 1024"
  else if port > 65535 then
    .error "port must be <= 65535"
  else if timeout = 0 then
    .error "timeout must be > 0"
  else
    .ok { port := port, timeout := timeout }

def configValidationTests : TestSuite :=
  (TestSuite.empty "Config Validation")
  |>.addTest "valid config passes" (do
      return assertOk (parseConfig 8080 30))
  |>.addTest "port too low fails" (do
      return assertError (parseConfig 80 30))
  |>.addTest "port too high fails" (do
      return assertError (parseConfig 70000 30))
  |>.addTest "zero timeout fails" (do
      return assertError (parseConfig 8080 0))
  |>.addTest "valid config has correct values" (do
      match parseConfig 8080 30 with
      | .ok config =>
        if config.port == 8080 && config.timeout == 30 then
          return assert true
        else
          return assert false "Config values incorrect"
      | .error _ =>
        return assert false "Config parsing should have succeeded")

/-- Main function to run all tests -/
def main : IO UInt32 := do
  runTestSuitesWithExitCode [
    rangeTests,
    exceptTests,
    exceptOperationTests,
    ioTests,
    customMessageTests,
    configValidationTests
  ]
