# Contributing

We welcome contributions! Please follow these guidelines:

## Development Setup

```bash
git clone https://github.com/yourusername/sqlite_crypto.git
cd sqlite_crypto
bundle install
```

## Running Tests

```bash
bundle exec rspec
```

## Code Style

We use StandardRB for linting:

```bash
bundle exec standardrb
```

To automatically fix issues:

```bash
bundle exec standardrb --fix
```

## Submitting Changes

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Write/update tests
5. Run `bundle exec rspec` to verify tests pass
6. Run `bundle exec standardrb --fix` to fix style issues
7. Commit: `git commit -am 'Add your feature'`
8. Push: `git push origin feature/your-feature`
9. Submit a pull request

## Code of Conduct

Please be respectful and inclusive. This is a welcoming community.