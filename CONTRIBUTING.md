# Contributing to Claude Code Statusline

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:

- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Your environment (macOS version, Swift version, Claude Code version)
- Any error messages or logs

### Suggesting Enhancements

Enhancement suggestions are welcome! Please open an issue with:

- A clear description of the enhancement
- Why this enhancement would be useful
- Examples of how it would work

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Test thoroughly** - ensure your changes work on macOS
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

## Development Guidelines

### Code Style

**Bash Scripts:**
- Use 2 spaces for indentation
- Add comments for complex logic
- Use descriptive variable names
- Quote variables to prevent word splitting

**Swift Code:**
- Follow Swift standard conventions
- Use 4 spaces for indentation
- Add comments for public functions
- Handle errors gracefully

### Testing

Before submitting a PR:

1. **Test the installation script:**
   ```bash
   ./install.sh
   ```

2. **Test the Swift script:**
   ```bash
   swift scripts/fetch-claude-usage.swift
   ```

3. **Test the statusline:**
   ```bash
   echo '{"workspace":{"current_dir":"'"$(pwd)"'"}}' | bash scripts/statusline-command.sh
   ```

4. **Test on a clean system if possible**

### Documentation

- Update README.md if you add features
- Add examples to docs/ if appropriate
- Update TROUBLESHOOTING.md for known issues
- Comment complex code

## Project Structure

```
claude-code-statusline/
├── README.md                 # Main documentation
├── LICENSE                   # MIT license
├── install.sh               # Installation script
├── scripts/
│   ├── fetch-claude-usage.swift    # Swift API fetcher
│   └── statusline-command.sh       # Statusline formatter
├── docs/
│   ├── TROUBLESHOOTING.md   # Troubleshooting guide
│   └── CUSTOMIZATION.md     # Customization guide
└── examples/
    └── settings.json        # Example configuration
```

## What We're Looking For

### High Priority

- **Bug fixes** - especially for edge cases
- **Performance improvements** - making scripts faster
- **Better error handling** - clearer error messages
- **Documentation improvements** - making it easier to use

### Medium Priority

- **New customization options** - more ways to format the statusline
- **Additional metrics** - showing different usage stats
- **Compatibility** - ensuring it works across macOS versions

### Nice to Have

- **Example configurations** - creative statusline formats
- **Automated tests** - for better reliability
- **CI/CD setup** - automated testing

## Code of Conduct

- Be respectful and welcoming
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards other community members

## Questions?

- Open an issue for general questions
- Tag issues with `question` label
- Check existing issues first

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing! 🎉
