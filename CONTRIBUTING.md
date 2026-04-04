# Contributing to MatSciTools

Thank you for your interest in contributing to MatSciTools! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork:
   ```
   git clone https://github.com/YOUR-USERNAME/MatSciTools.git
   ```
3. **Set up** your environment:
   ```matlab
   cd MatSciTools
   setup()
   ```
4. **Run tests** to make sure everything works:
   ```matlab
   results = run_all_tests();
   ```

## How to Contribute

### Reporting Bugs

- Open a [GitHub Issue](../../issues) with:
  - MATLAB version (`ver`)
  - Operating system
  - Steps to reproduce
  - Expected vs actual behavior
  - Error messages (full stack trace)

### Suggesting Features

- Open a [GitHub Issue](../../issues) with the `enhancement` label
- Describe the use case and proposed behavior
- Reference relevant MSE standards or literature if applicable

### Submitting Code

1. Create a feature branch from `main`:
   ```
   git checkout -b feature/your-feature-name
   ```
2. Make your changes following the coding conventions below
3. Add or update tests in `tests/`
4. Run the full test suite and ensure all tests pass
5. Submit a Pull Request with a clear description

## Coding Conventions

### File Organization

- All public functions go in package directories (`+matdb/`, `+matsel/`, etc.)
- Test files go in `tests/` with the naming pattern `test_*.m`
- Demo scripts go in `examples/` with the naming pattern `demo_*.m`

### Naming

- **Functions**: `snake_case` (e.g., `generate_sample`, `fit_peaks`)
- **Variables**: `camelCase` (e.g., `peakPositions`, `grainSize`)
- **Classes**: `PascalCase` (e.g., `MatSciApp`)
- **Constants**: `UPPER_CASE` (e.g., `MAX_ITERATIONS`)

### Code Style

- Use MATLAB `arguments` blocks for input validation (R2020a+)
- Use `inputParser` for optional name-value parameters
- Return results as structs (not individual outputs) for complex returns
- Every public function must have a help block with:
  - One-line summary (`H1` line)
  - Description of inputs/outputs
  - At least one usage example
- Prefer base MATLAB implementations over toolbox-dependent code
- Use `regexprep` to sanitize strings for filesystem operations

### Testing

- Write tests using the `matlab.unittest.TestCase` framework
- Each module should have a corresponding `test_<module>.m` file
- Tests should be self-contained (no external data dependencies)
- Use `verifyEqual`, `verifyTrue`, `verifyError`, etc.
- Aim for coverage of edge cases and error conditions

### Example Test

```matlab
classdef test_example < matlab.unittest.TestCase
    methods (Test)
        function test_basic_operation(testCase)
            result = mymodule.my_function(input);
            testCase.verifyEqual(result.field, expected_value, 'AbsTol', 1e-6);
        end

        function test_error_handling(testCase)
            testCase.verifyError(@() mymodule.my_function('bad'), ...
                'mymodule:invalidInput');
        end
    end
end
```

## Adding a New Module

1. Create a new package directory: `+mymodule/`
2. Add functions following the namespace pattern
3. Create `tests/test_mymodule.m` with comprehensive tests
4. Create `examples/demo_mymodule.m` with usage examples
5. Update `matscitools.m` to list the new module
6. Update `README.md` and `docs/API_REFERENCE.md`
7. Update `compile_standalone.m` to include the new package

## Pull Request Checklist

- [ ] Code follows the naming and style conventions
- [ ] All new functions have help blocks with examples
- [ ] Tests added/updated and all passing (`run_all_tests()`)
- [ ] Demo script updated if adding user-facing features
- [ ] Documentation updated (README, API_REFERENCE)
- [ ] No toolbox dependencies added without discussion

## Code of Conduct

- Be respectful and constructive in all interactions
- Focus on technical merit and educational value
- Welcome contributors of all experience levels

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
