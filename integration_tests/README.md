# Integration and acceptance tests and tools.

This folder contains integration and acceptance tests for the OpenReception
project, plus a small set of convenience utilities that uses the, rather large,
test framework written specifically for the OpenReception project.

## Notes on tests

Currently, all tests are launched from the `all_tests.dart` file. The motivation
for this is is that there is a "magic" order in which the tests must run.
The reason for this is that before tests are run, we need to detect certain
environment details - such as external IP address for use with FreeSWITCH
processes.

## Test structuring

Every set of test should be in its own unique `group`, which has _at most_
one `setUp` and _at most_ one `tearDown` function. The reason for this, is that
`setUp` and `tearDown` functions are not replaced, but stacked if declared twice
within the same `group`. So, for instance, if a group has two `setUp`
declarations, then both of these functions will run - after the declaration of
the second. Example:

````dart
group('test-group', () {

  setUp(() {
    initializeStuff();
  });

  tearDown(()  {
    terminateStuff();
  });

  test('test-1', doTest);

  setUp(() {
    initializeStuff();
    initializeOtherStuff();
  });

  tearDown(()  {
    terminateStuff();
    terminateOtherStuff();
  });

  test('test-2', doTest);

````
In the above example, the function `initializeStuff()` will be called once
before `test-1`, but twice before `test-2` due to the stacking of `setUp`
functions.

In order to remedy this, you must write a new `group` block - using the same
name, if the tests are coherent.
Example:

````dart
group('test-group', () {

  setUp(() {
    initializeStuff();
  });

  tearDown(()  {
    terminateStuff();
  });

  test('test-1', doTest);
});
group('test-group', () {

  setUp(() {
    initializeStuff();
    initializeOtherStuff();
  });

  tearDown(()  {
    terminateStuff();
    terminateOtherStuff();
  });

  test('test-2', doTest);

````
This way, only one `setUp` and one `tearDown` function will be called.
