# LeanTest

A unit testing framework for Lean 4 with an API inspired by Elixir's ExUnit. LeanTest provides an expressive, easy-to-use testing interface for writing and running tests in Lean.

## Features

- **Elixir-style API**: Familiar syntax for developers coming from Elixir/ExUnit
- **Rich Assertions**: Comprehensive set of assertion functions
- **Colorized Output**: Clear, colorful test results in the terminal
- **Test Organization**: Group tests into test suites for better organization
- **Custom Messages**: Add custom error messages to assertions

## Installation

This is a standalone Lean 4 project. To use it:

1. Clone or copy this repository
2. Build the project:
```bash
lake build
```

## Quick Start

Here's a simple example similar to Elixir's ExUnit:

```lean
import LeanTest

open LeanTest

/-- Define a test suite -/
def myTests : TestSuite :=
  (TestSuite.empty "My First Tests")
  |>.addTest "addition works" (do
      return assertEqual 4 (2 + 2))
  |>.addTest "strings concatenate" (do
      return assertEqual "hello world" ("hello" ++ " " ++ "world"))
  |>.addTest "boolean assertion" (do
      return assertTrue true)

/-- Run the tests -/
def main : IO UInt32 := do
  runTestSuitesWithExitCode [myTests]
```

## API Reference

### Assertions

LeanTest provides the following assertion functions (similar to ExUnit):

#### `assert`
Assert that a boolean condition is true.
```lean
assert (5 > 3)
assert (x == y) "x and y should be equal"
```

#### `assertEqual`
Assert that two values are equal.
```lean
assertEqual 10 (5 + 5)
assertEqual "hello" myString "Should greet with hello"
```

#### `assertNotEqual`
Assert that two values are not equal.
```lean
assertNotEqual 5 10
assertNotEqual "foo" "bar"
```

#### `refute`
Refute that a condition is true (assert it's false).
```lean
refute (5 < 3)
refute isEmpty "List should not be empty"
```

#### `assertTrue` / `assertFalse`
Assert that a boolean value is true or false.
```lean
assertTrue (isEven 4)
assertFalse (isOdd 4)
```

#### `assertSome` / `assertNone`
Assert that an Option is Some or None.
```lean
assertSome (some 42)
assertNone (none : Option Nat)
```

#### `assertEmpty`
Assert that a list is empty.
```lean
assertEmpty ([] : List Nat)
```

#### `assertContains`
Assert that a list contains an element.
```lean
assertContains [1, 2, 3, 4] 3
```

### Test Organization

#### Creating Test Suites
```lean
def myTestSuite : TestSuite :=
  (TestSuite.empty "Suite Name")
  |>.addTest "test description 1" (do
      return assertEqual expected actual)
  |>.addTest "test description 2" (do
      return assertTrue condition)
```

#### Running Tests

**For CI/CD (recommended):**
```lean
def main : IO UInt32 := do
  -- Returns exit code: 0 if all tests pass, 1 if any fail
  runTestSuitesWithExitCode [suite1, suite2, suite3]
```

**For interactive use:**
```lean
def main : IO Unit := do
  -- Always exits with code 0
  runTestSuites [suite1, suite2, suite3]
```

## Examples

The `examples/` directory contains several example test files:

### BasicTest.lean
Demonstrates basic assertions with arithmetic, boolean, and string tests.

**Run it:**
```bash
lake env lean examples/BasicTest.lean
```

### CollectionTest.lean
Shows how to test lists, options, and custom data structures.

**Run it:**
```bash
lake env lean examples/CollectionTest.lean
```

### CustomMessageTest.lean
Examples of custom error messages and function testing.

**Run it:**
```bash
lake env lean examples/CustomMessageTest.lean
```

## Comparison with Elixir's ExUnit

If you're familiar with Elixir's ExUnit, here's how LeanTest maps to ExUnit concepts:

| ExUnit | LeanTest | Example |
|--------|----------|---------|
| `test "description"` | `.addTest "description"` | Test definition |
| `assert` | `assert` | Boolean assertion |
| `assert x == y` | `assertEqual x y` | Equality assertion |
| `refute` | `refute` | Refute assertion |
| `describe` | `TestSuite.empty "name"` | Test grouping |
| `ExUnit.run()` | `runTestSuites [...]` | Run tests |

### ExUnit Example:
```elixir
defmodule MathTest do
  use ExUnit.Case

  describe "addition" do
    test "adds two numbers" do
      assert 2 + 2 == 4
    end

    test "is commutative" do
      assert 3 + 5 == 5 + 3
    end
  end
end
```

### LeanTest Equivalent:
```lean
def mathTests : TestSuite :=
  (TestSuite.empty "addition")
  |>.addTest "adds two numbers" (do
      return assertEqual 4 (2 + 2))
  |>.addTest "is commutative" (do
      return assertEqual (3 + 5) (5 + 3))

def main : IO UInt32 := do
  runTestSuitesWithExitCode [mathTests]
```

## Output Format

LeanTest provides colorized terminal output:

```
Arithmetic Tests
  ✓ addition works correctly
  ✓ subtraction works correctly
  ✓ multiplication works correctly

Boolean Tests
  ✓ assert true condition
  ✗ this test failed
    Expected: true
    Actual: false

Test Summary:
  Total:  5
  Passed: 4
  Failed: 1

FAILED
```

## Writing Your Own Tests

1. Create a new `.lean` file in your project
2. Import LeanTest: `import LeanTest`
3. Open the namespace: `open LeanTest`
4. Define your test suites using `TestSuite.empty` and `.addTest`
5. Create a `main` function that calls `runTestSuitesWithExitCode` (for CI) or `runTestSuites` (for interactive use)
6. Run with: `lake env lean --run your_test_file.lean`

### Exit Codes for CI/CD

When using `runTestSuitesWithExitCode`, your test executable will:
- Return **exit code 0** if all tests pass
- Return **exit code 1** if any tests fail

This makes it easy to integrate with CI/CD pipelines:

```bash
lake env lean --run tests/MyTests.lean
# Exit code will be non-zero if tests fail, failing the CI build
```

## Advanced Usage

### Custom Data Types

You can test custom data types as long as they derive `BEq` and `Repr`:

```lean
structure Point where
  x : Int
  y : Int
  deriving Repr, BEq

def pointTests : TestSuite :=
  (TestSuite.empty "Point Tests")
  |>.addTest "points are equal" (do
      return assertEqual (Point.mk 1 2) (Point.mk 1 2))
```

### Testing Functions

```lean
def fibonacci : Nat → Nat
  | 0 => 0
  | 1 => 1
  | n + 2 => fibonacci n + fibonacci (n + 1)

def fibTests : TestSuite :=
  (TestSuite.empty "Fibonacci Tests")
  |>.addTest "fib(0) = 0" (do
      return assertEqual 0 (fibonacci 0))
  |>.addTest "fib(5) = 5" (do
      return assertEqual 5 (fibonacci 5))
```

## Contributing

Contributions are welcome! Feel free to:
- Add new assertion types
- Improve error messages
- Add more examples
- Enhance the test runner

## License

Apache License 2.0 - See [LICENSE](LICENSE) file for details

## Acknowledgments

Inspired by Elixir's ExUnit testing framework.