---
name: matlab-module
description: Scaffold a new MatSciTools module with function files, tests, demo script, and documentation following project conventions (snake_case functions, camelCase variables, arguments blocks, package namespaces).
author: MatSciTools
---

# Scaffold a New MatSciTools Module

Creates a complete MatSciTools module following project conventions. Collects the module name, function list, and descriptions from the user, then generates all files and updates documentation.

## Conventions

- **Function names**: `snake_case` (e.g., `find_peaks`, `grain_size`)
- **Local variables**: `camelCase` (e.g., `numLines`, `inputData`)
- **Package folders**: `+modulename/` at the project root
- **No toolbox dependencies**: Prefer base MATLAB functions. If a toolbox is truly needed, document it and provide a fallback.
- **Input validation**: Use `arguments` blocks (R2019b+) for simple signatures, or `inputParser` for variable name-value pairs (`varargin`). Match whichever pattern best fits the function — see existing modules for examples.
- **Complex outputs**: Return `struct` arrays for multi-field results.
- **Error IDs**: Use `modulename:ErrorType` format (e.g., `matdb:NotFound`, `xrd:InvalidInput`).

## Workflow

When the user asks to create a new module, follow this checklist:

### Step 0 — Gather Information

Ask the user for:
1. Module name (lowercase, no spaces — becomes the `+package` folder and namespace)
2. List of public functions with one-line descriptions
3. Brief module description (for README and `matscitools.m`)

### Step 1 — Create the Package Folder

Create `+modulename/` at the workspace root.

If the module needs private helper functions, also create `+modulename/private/`.

### Step 2 — Create Function Files

For each function, create `+modulename/function_name.m` with this structure:

```matlab
function output = function_name(requiredArg, options)
%MODULENAME.FUNCTION_NAME One-line description
%   OUTPUT = MODULENAME.FUNCTION_NAME(REQUIREDARG) detailed description
%   of what the function does and how it works.
%
%   Optional Parameters (Name-Value):
%     'ParamName'  - Description (default: value)
%
%   Returns a struct with:
%     field1 - Description
%     field2 - Description
%
%   Example:
%     result = modulename.function_name(input, 'Param', value);

    arguments
        requiredArg     (1,1) double {mustBePositive}
        options.ParamName (1,1) double = 10
    end

    % Implementation
end
```

Key rules for function files:
- **H1 line**: `%MODULENAME.FUNCTION_NAME One-line description` (uppercase namespace.FUNCTION_NAME)
- **Help block**: Inputs, outputs, optional parameters with defaults, at least one example
- **arguments block** or **inputParser**: Use `arguments` for fixed parameter lists; use `inputParser` with `varargin` when the function accepts arbitrary name-value pairs (see `+microstructure/grainsize.m` or `+matsel/ashby.m` for inputParser examples)
- **Error IDs**: `'modulename:ErrorType'` — always use the module namespace
- **Return structs** for complex multi-field outputs

### Step 3 — Create Test File

Create `tests/test_modulename.m` as a `matlab.unittest.TestCase` subclass. Follow the pattern in `tests/test_matdb.m`:

```matlab
classdef test_modulename < matlab.unittest.TestCase
%TEST_MODULENAME Unit tests for the modulename module

    methods (Test)
        function testFunctionNameBasic(testCase)
            result = modulename.function_name(input);
            testCase.verifyClass(result, 'struct');
            testCase.verifyTrue(isfield(result, 'expectedField'));
        end

        function testFunctionNameEdgeCase(testCase)
            % Test boundary conditions or empty inputs
            result = modulename.function_name(edgeInput);
            testCase.verifyEmpty(result);
        end

        function testFunctionNameInvalidInput(testCase)
            testCase.verifyError(@() modulename.function_name('bad'), ...
                'modulename:InvalidInput');
        end
    end
end
```

Test requirements:
- At least **one happy-path test per function**
- At least **one edge-case test** (empty input, boundary values)
- At least **one error test** using `verifyError` with the expected error ID
- Use `testCase.verifyClass`, `verifyEqual`, `verifyTrue`, `verifyGreaterThan`, `verifyEmpty`, `verifyError`
- Test method names: `testFunctionNameDescriptiveAction` (camelCase)

### Step 4 — Create Demo Script

Create `examples/demo_modulename.m` using `%%` section breaks so users can step through with Ctrl+Enter:

```matlab
%% MatSciTools Demo: Module Display Name
% This demo shows how to use the modulename module to ...

%% Setup
addpath(fileparts(fileparts(mfilename('fullpath'))));

%% 1. First Feature
fprintf('=== Section Title ===\n');
result = modulename.function_name(input);
disp(result);

%% 2. Second Feature
fprintf('=== Another Section ===\n');
% Show another function or workflow
```

Key rules:
- Start with `%% MatSciTools Demo: <Title>` and a description comment
- `%% Setup` section that adds the project root to the path
- Number the sections: `%% 1.`, `%% 2.`, etc.
- Use `fprintf` for section headers, `disp` for results
- Show realistic, runnable examples

### Step 5 — Update `matscitools.m`

Add the new module to both the help block and the `fprintf` display section:

1. Add to the `%   Modules:` list in the help comment (around line 6–13)
2. Add a matching `fprintf` line in the display section (around line 25–32)

Follow the existing alignment — module names are left-padded to 15 characters.

### Step 6 — Update `README.md`

Add a row to the **Modules** table (the `| Module | Namespace | Functions | Description |` table around line 126–136):

```markdown
| **Module Name** | `modulename` | `func1`, `func2`, `func3` | Short description |
```

Also update the module count in the introduction paragraph if it mentions a specific number.

### Step 7 — Update `docs/API_REFERENCE.md`

Add a new section for the module following the existing format:

```markdown
## Module Name (`modulename`)

### `modulename.function_name`

Description.

**Syntax:**
\```matlab
result = modulename.function_name(arg)
result = modulename.function_name(arg, 'Param', value)
\```

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg` | `double` | Description |
| `'Param'` | `double` (optional) | Description (default: value) |

**Returns:** `struct` with fields ...

\```matlab
result = modulename.function_name(42, 'Param', 10);
\```
```

### Step 8 — Verify

After generating all files, print this checklist for the user:

- [ ] `+modulename/` folder created with all function files
- [ ] `+modulename/private/` created (if needed for internal helpers)
- [ ] `tests/test_modulename.m` created with happy-path, edge-case, and error tests
- [ ] `examples/demo_modulename.m` created with `%%` sections
- [ ] `matscitools.m` updated (help block + fprintf display)
- [ ] `README.md` Modules table updated
- [ ] `docs/API_REFERENCE.md` updated with function documentation
- [ ] All functions use `arguments` blocks or `inputParser` for validation
- [ ] Error IDs follow `modulename:ErrorType` pattern
- [ ] No toolbox dependencies (base MATLAB only)

## Reference Files

When scaffolding, read these files to match current conventions:
- `+matdb/get.m` — Simple function with input validation and error IDs
- `+matdb/search.m` — varargin-based function with property-value pairs
- `+microstructure/grainsize.m` — inputParser pattern with optional name-value parameters
- `tests/test_matdb.m` — Test class structure with happy-path, edge-case, and error tests
- `examples/demo_material_database.m` — Demo script with `%%` section breaks
- `matscitools.m` — Module listing format
- `docs/API_REFERENCE.md` — API documentation format
