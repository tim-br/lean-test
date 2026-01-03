/-
Real-world example: Testing a Stack data structure.
This demonstrates testing actual Lean code with state and operations.
-/

import LeanTest

open LeanTest

/-- A stack data structure using a list as the underlying storage -/
structure Stack (α : Type) where
  items : List α
  deriving Repr, BEq

namespace Stack

/-- Create an empty stack -/
def empty : Stack α :=
  { items := [] }

/-- Check if the stack is empty -/
def isEmpty (s : Stack α) : Bool :=
  s.items.isEmpty

/-- Get the size of the stack -/
def size (s : Stack α) : Nat :=
  s.items.length

/-- Push an element onto the stack -/
def push (s : Stack α) (x : α) : Stack α :=
  { items := x :: s.items }

/-- Pop an element from the stack -/
def pop (s : Stack α) : Option (α × Stack α) :=
  match s.items with
  | [] => none
  | x :: xs => some (x, { items := xs })

/-- Peek at the top element without removing it -/
def peek (s : Stack α) : Option α :=
  s.items.head?

/-- Convert stack to list (top to bottom) -/
def toList (s : Stack α) : List α :=
  s.items

/-- Create a stack from a list -/
def fromList (xs : List α) : Stack α :=
  { items := xs }

end Stack

/-- Tests for stack creation and basic properties -/
def stackCreationTests : TestSuite :=
  (TestSuite.empty "Stack Creation")
  |>.addTest "empty stack is empty" (do
      let s := Stack.empty (α := Nat)
      return assertTrue s.isEmpty)
  |>.addTest "empty stack has size 0" (do
      let s := Stack.empty (α := Nat)
      return assertEqual 0 s.size)
  |>.addTest "empty stack peek returns none" (do
      let s := Stack.empty (α := Nat)
      return assertNone s.peek)
  |>.addTest "fromList creates correct stack" (do
      let s := Stack.fromList [1, 2, 3]
      return assertEqual [1, 2, 3] s.toList)

/-- Tests for push operation -/
def stackPushTests : TestSuite :=
  (TestSuite.empty "Stack Push")
  |>.addTest "push to empty stack" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 42
      return assertEqual (some 42) s'.peek)
  |>.addTest "push increases size" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 1
      return assertEqual 1 s'.size)
  |>.addTest "push multiple elements" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 1 |>.push 2 |>.push 3
      return assertEqual 3 s'.size)
  |>.addTest "push maintains LIFO order" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 1 |>.push 2 |>.push 3
      return assertEqual (some 3) s'.peek)
  |>.addTest "stack is not empty after push" (do
      let s := Stack.empty (α := String)
      let s' := s.push "hello"
      return assertFalse s'.isEmpty)

/-- Tests for pop operation -/
def stackPopTests : TestSuite :=
  (TestSuite.empty "Stack Pop")
  |>.addTest "pop from empty stack returns none" (do
      let s := Stack.empty (α := Nat)
      return assertNone s.pop)
  |>.addTest "pop returns top element" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 42
      match s'.pop with
      | some (value, _) => return assertEqual 42 value
      | none => return assert false "Expected some, got none")
  |>.addTest "pop removes element" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 42
      match s'.pop with
      | some (_, s'') => return assertTrue s''.isEmpty
      | none => return assert false "Expected some, got none")
  |>.addTest "pop decreases size" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 1 |>.push 2
      match s'.pop with
      | some (_, s'') => return assertEqual 1 s''.size
      | none => return assert false "Expected some, got none")
  |>.addTest "pop maintains order" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 1 |>.push 2 |>.push 3
      match s'.pop with
      | some (val, s'') =>
        match s''.pop with
        | some (val2, _) => return assertEqual [3, 2] [val, val2]
        | none => return assert false "Second pop failed"
      | none => return assert false "First pop failed")

/-- Tests for peek operation -/
def stackPeekTests : TestSuite :=
  (TestSuite.empty "Stack Peek")
  |>.addTest "peek doesn't modify stack" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 42
      let _ := s'.peek
      return assertEqual 1 s'.size)
  |>.addTest "peek returns correct value" (do
      let s := Stack.empty (α := String)
      let s' := s.push "first" |>.push "second"
      return assertEqual (some "second") s'.peek)
  |>.addTest "peek after pop shows next element" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 1 |>.push 2 |>.push 3
      match s'.pop with
      | some (_, s'') => return assertEqual (some 2) s''.peek
      | none => return assert false "Pop failed")

/-- Tests for complex stack operations -/
def stackComplexTests : TestSuite :=
  (TestSuite.empty "Stack Complex Operations")
  |>.addTest "push and pop sequence" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 1 |>.push 2 |>.push 3
      match s'.pop with
      | some (_, s1) =>
        match s1.pop with
        | some (_, s2) =>
          match s2.pop with
          | some (_, s3) => return assertTrue s3.isEmpty
          | none => return assert false "Third pop failed"
        | none => return assert false "Second pop failed"
      | none => return assert false "First pop failed")
  |>.addTest "stack with different types - strings" (do
      let s := Stack.empty (α := String)
      let s' := s.push "hello" |>.push "world"
      return assertEqual (some "world") s'.peek)
  |>.addTest "toList preserves order" (do
      let s := Stack.empty (α := Nat)
      let s' := s.push 1 |>.push 2 |>.push 3
      return assertEqual [3, 2, 1] s'.toList)
  |>.addTest "fromList and toList are consistent" (do
      let original := [5, 4, 3, 2, 1]
      let s := Stack.fromList original
      return assertEqual original s.toList)
  |>.addTest "large stack operations" (do
      let s := Stack.empty (α := Nat)
      let s' := (List.range 100).foldl (fun acc n => acc.push n) s
      return assertEqual 100 s'.size)

/-- Main function to run all stack tests -/
def main : IO UInt32 := do
  runTestSuitesWithExitCode [
    stackCreationTests,
    stackPushTests,
    stackPopTests,
    stackPeekTests,
    stackComplexTests
  ]
