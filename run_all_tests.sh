#!/bin/bash
set -e

echo "Building LeanTest..."
lake build

echo ""
echo "Running all tests..."
echo ""

TOTAL_TESTS=0
FAILED=0

run_test() {
  local test_name=$1
  local test_file=$2

  echo "=== Running $test_name ==="
  if lake env lean --run "$test_file"; then
    echo "✅ $test_name passed"
  else
    echo "❌ $test_name failed"
    FAILED=$((FAILED + 1))
  fi
  echo ""
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

run_test "BasicTest" "examples/BasicTest.lean"
run_test "CollectionTest" "examples/CollectionTest.lean"
run_test "CustomMessageTest" "examples/CustomMessageTest.lean"
run_test "StackTest" "examples/StackTest.lean"
run_test "AdvancedAssertionsTest" "examples/AdvancedAssertionsTest.lean"

echo "================================"
echo "Test Summary"
echo "================================"
echo "Total test suites: $TOTAL_TESTS"
echo "Passed: $((TOTAL_TESTS - FAILED))"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo "✅ All test suites passed!"
  exit 0
else
  echo "❌ Some test suites failed!"
  exit 1
fi
