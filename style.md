# Code conventions

## Rules

- Variables scoped inside functions **must** be declared with `local` keyword.
- Variables globally scoped **must** be declared with `typeset` keyword.
- Functions **must** be declared with `function` keyword.
- Functions and variables names **must** be camel-cased with the exception of their prefix segment (see bellow).
- Local variables **must** be prefixed with an underscore `_` unless they are local environment variables such as `IFS`.
- Nested functions **must** be prefixed an underscore `_`.
- Local variables **must** be defined at the very top of every function.
- Nested functions **must** be declared right bellow local variables declarations.
- Function parameters **must** be named with a `local -r` (readonly) variable definitions at the very begining of function declaration.
- Prefer longer, descriptive identifiers over shorter, abbreviated ones.
- Functions in the global scope **must** be prefixed with the module name they belong to followed by an underscore `_`.
- Long functions (over 30 lines) **should** be deconstructed in multiple small functions, and declared _inside_ this function.
- Boolean values **should** be represented as text variables with value true or false.

## Function Prefixes

Module prefixes determine to which “virtual module” a function belongs, and greatly limit risk of collusion.
Also, an implicit rule of the level metric is that lower level functions can never invoke higher level ones.
Here is a table with description:

| module            | prefix  | level | description                           |
| :---------------- | ------- | :---: | ------------------------------------- |
| primitive         | `prim_` |   1   | Primitive utilities                   |
| terminal          | `term_` |   1   | Terminal utilities                    |
| filesystem        | `fs_`   |   1   | Filesystem utilities                  |
| program           | `prog_` |   1   | Process and program-related utilities |
| assert            | `asrt_` |   2   | Assertions operations                 |
| device and images | `devi_` |   2   | Devices and images operations         |
| steps             | `step_` |   3   | High-level program execution step     |
| action execution  | `exec_` |   4   | Functions encapsulating an “action”   |

## Variable Prefixes

The prefixes can be the same as function namespace prefixes for constant (readonly) declarations.
Non-constants should be prefixed with `st_` for “stateful”, with the exception of variables assigned from user parameters which can be unprefixed.

|   Constant? (readonly)   |    Belongs to module?    |   Contains parameters?   | Prefix                        |
| :----------------------: | :----------------------: | :----------------------: | ----------------------------- |
|    :heavy_check_mark:    | :heavy_multiplication_x: | :heavy_multiplication_x: | `ct_` for “constant“          |
|    :heavy_check_mark:    |    :heavy_check_mark:    | :heavy_multiplication_x: | _module prefix_, e.g. `asrt_` |
| :heavy_multiplication_x: | :heavy_multiplication_x: | :heavy_multiplication_x: | `st_` for “stateful”          |
| :heavy_multiplication_x: | :heavy_multiplication_x: |    :heavy_check_mark:    | _no prefix_                   |
