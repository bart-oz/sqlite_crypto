# Contributing to sqlite_crypto

Thank you for your interest in contributing! This guide will help you get started.

## Development Setup

```bash
# Fork the repository on GitHub first, then:
git clone https://github.com/YOUR_USERNAME/sqlite_crypto.git
cd sqlite_crypto
bundle install

# Generate appraisal gemfiles for multi-Rails testing
bundle exec appraisal install
```

## Running Tests Locally

Before submitting a PR, ensure all checks pass locally:

```bash
# Run the test suite
bundle exec rspec

# Run tests against a specific Rails version
bundle exec appraisal rails-8.1 rspec

# Run linter
bundle exec standardrb

# Auto-fix linting issues
bundle exec standardrb --fix
```

## Submitting Changes

### 1. Create a Feature Branch

```bash
git checkout -b feat/your-feature-name
# or for bug fixes:
git checkout -b fix/issue-description
```

### 2. Make Your Changes

- Write clear, focused commits
- Add tests for new functionality
- Update documentation if needed

### 3. Verify All Checks Pass

```bash
bundle exec rspec              # All tests must pass
bundle exec standardrb         # No linting errors
```

### 4. Push and Open a Pull Request

```bash
git push origin feat/your-feature-name
```

Then open a Pull Request on GitHub against the `main` branch.

## What Happens After You Open a PR

1. **Automated CI runs** - Your PR will be tested against:
   - Ruby 3.1, 3.2, 3.3, 3.4 and 4.0
   - Rails 7.1, 7.2, 8.0, and 8.1
   - StandardRB linting
   - Security vulnerability audit

2. **All checks must pass** - The PR cannot be merged until CI is green.

3. **Maintainer review** - A maintainer will review your code and may:
   - Approve it for merging
   - Request changes (please address feedback and push new commits)
   - Ask questions or suggest improvements

4. **Keep your branch updated** - If `main` has changed, update your branch:
   ```bash
   git fetch upstream
   git rebase upstream/main
   git push --force-with-lease origin feature/your-feature-name
   ```

5. **Merge** - Once approved and CI passes, a maintainer will merge your PR.

## Pull Request Guidelines

- **One feature per PR** - Keep changes focused and reviewable
- **Descriptive title** - Use clear titles like "Add UUID generation helper" or "Fix ULID validation for edge cases"
- **Link issues** - Reference related issues with "Fixes #123" or "Relates to #456"
- **Update CHANGELOG** - Add your changes under `[Unreleased]`

## Code Style

We use [StandardRB](https://github.com/standardrb/standard) for consistent code style. The linter runs automatically in CI, but you can check locally:

```bash
bundle exec standardrb         # Check for issues
bundle exec standardrb --fix   # Auto-fix issues
```

## Testing Guidelines

- Write tests for all new functionality
- Place specs in `spec/lib/` mirroring the `lib/` structure
- Use descriptive `it` blocks: `it "validates UUID format with hyphens"`
- Test edge cases and error conditions

## Questions?

- Open an issue for bugs or feature requests
- Start a discussion for questions or ideas

## Code of Conduct

Please be respectful and inclusive. We're building a welcoming community where everyone can contribute regardless of experience level.

---

Thank you for helping make sqlite_crypto better! 🙏