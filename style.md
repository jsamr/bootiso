# Code Style and Conventions

## Rules

- Variables scoped inside functions **must** be declared with `local` keyword.
- Variables globally scoped **must** be declared with `typeset` keyword.
- Identifiers **must** be camel-cased with the exception of their prefix segment (see below).
- Prefer longer, descriptive identifiers over shorter, abbreviated ones.
- Local variables **must** be prefixed with an underscore `_` unless they are local environment variables such as `IFS`.
- Local variables **must** be defined at the very top of every function.
- Functions **must** be declared with `function` keyword.
- Nested functions **must** be prefixed with an underscore `_`.
- Nested functions **must** be declared right below local variables declarations.
- Function parameters **must** be named with a `local -r` (readonly) variable definitions at the very begining of function declaration.
- Functions in the global scope **must** be prefixed with the module name they belong to followed by an underscore `_`.
- Long functions (over 30 lines) **should** be deconstructed in multiple small functions, and declared _inside_ this function.
- Boolean values **should** be represented as strings with value true or false, unless testing for return status.

## Module System

Module prefixes act like namespaces to determine to which “virtual module” a function or global readonly variable belongs.
It limits risks of collusion and help readability.

To each module is attributed a level. Level 1 contains simple and reusable functions
while higher values mean greater abstractions. An implicit rule of the level metric is that lower level functions cannot invoke higher level ones.
Below is a list of modules with their description. The level system is made such that
the `main` function almost exclusively invoke a couple of functions from “action exec” and “steps”
modules, in a way that makes the program execution easy to grasp and deconstruct.

### Modules List

| module            | prefix  | level | examples                                |
| :---------------- | ------- | :---: | --------------------------------------- |
| sh                | `sh_`   |   1   | String and array transforms, formatting |
| terminal          | `term_` |   1   | Pretty printing to stdout               |
| filesystem        | `fs_`   |   1   | Creating temporary files                |
| system            | `sys_`  |   1   | Querying device type                    |
| process state     | `ps_`   |   2   | Handling failures, graceful exit        |
| assert            | `asrt_` |   2   | Checking image or target device         |
| device and images | `devi_` |   2   | Inspecting image                        |
| steps             | `step_` |   3   | High-level program execution step       |
| action exec       | `exec_` |   4   | Functions encapsulating an “action”     |

### Global Variables

Global mutable variables **must** be prefixed with `st_`,
with the exception of global variables assigned to user parameters which **must** be unprefixed.
Global readonly variables belonging to no module **must** be prefixed with `ct_`.

|   Readonly?   |    In module?    |   Contains parameters?   | Prefix                        |
| :----------------------: | :----------------------: | :----------------------: | ----------------------------- |
|    :heavy_check_mark:    | :heavy_multiplication_x: | :heavy_multiplication_x: | `ct_` for “constant“          |
|    :heavy_check_mark:    |    :heavy_check_mark:    | :heavy_multiplication_x: | _module prefix_, e.g. `asrt_` |
| :heavy_multiplication_x: | :heavy_multiplication_x: | :heavy_multiplication_x: | `st_` for “state”             |
| :heavy_multiplication_x: | :heavy_multiplication_x: |    :heavy_check_mark:    | _no prefix_                   |

### Modules Declaration

Module names **must** be at least 2 characters and maximum 4 characters.
To be easily identified in minimaps, modules names are commented in ASCII art _Roman_ font.
The recommended utility is **figlet**.

```bash
figlet -f Roman <name>
```
Example for "fs" module header:

``` bash
#  .o88o.          
#  888 `"          
# o888oo   .oooo.o 
#  888    d88(  "8 
#  888    `"Y88b.  
#  888    o.  )88b 
# o888o   8""888P'
# 
# FILESYTEM MODULE
```
