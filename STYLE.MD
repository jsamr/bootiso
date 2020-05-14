# Style guidelines

## Conventions

- Always prefer `local` over `declare` or `typeset` in functions
- Always prefer `typeset` over `declare` in global scope
- Always use camel-case for functions and variables
- Always prefix local function variables with an underscore `_`, with the exception of IFS.
- Always prefix nested functions with an underscore `_`.
- Always use namespace prefixes in functions (see section bellow).
- Local variables should be defined at the very top of every function.
- Global boolean values are represented as text variables with value true or false.
- Long functions (over 30 lines) should be deconstructed in multiple small functions, and declared *inside* this function.
- Nested functions should be declared right after local variables declarations.
- Function parameters should always be named with a `local -r` (readonly) variable definitions at the very begining of function declaration.

## Function Namespace Prefixes

Those prefixes help understanding to which “virtual module” a function belongs, and greatly limit risk of collusion.
Here is a table with description:

ARGS_: Utilities related to command arguments inspection
ASRT_: Utilities to perform assertions on contextual environment
TEXT_: Utilities related to text processing
DEVO_: Utilities related to device operations and information querying
FILE_: Utilities related to file searching
PRNT_: Utilities related to printing in console
DEPS_: Utilities related to dependency management
STEP_: High-level execution step

## Variable Namespace Prefixes

