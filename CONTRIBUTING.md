# Contributing to Planet ProTrader

Thank you for your interest in contributing to Planet ProTrader! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- iOS 17.0+ / macOS 14.0+
- Xcode 15.0+
- Swift 5.9+
- Git knowledge
- Understanding of trading concepts (helpful but not required)

### Development Setup
1. Fork the repository
2. Clone your fork locally
3. Open the project in Xcode
4. Create a new branch for your feature/fix
5. Make your changes
6. Test thoroughly
7. Submit a pull request

## 📝 Code Style Guidelines

### Swift Style
- Follow Apple's Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain consistency with existing code
- Add documentation for public APIs
- Use meaningful variable and function names

### Code Organization
- Keep files focused and cohesive
- Use appropriate access control
- Group related functionality
- Follow the existing project structure

### AI Engine Development
When contributing to AI engines:
- Maintain the engine interface pattern
- Add comprehensive testing
- Document performance characteristics
- Include example usage
- Ensure thread safety

## 🧪 Testing

### Requirements
- All new features must include tests
- Maintain or improve code coverage
- Test both success and failure cases
- Include performance tests for critical paths

### Testing Categories
- **Unit Tests**: Individual component testing
- **Integration Tests**: Cross-component functionality
- **Performance Tests**: Speed and memory usage
- **UI Tests**: User interface interactions

## 📋 Pull Request Process

### Before Submitting
1. Ensure all tests pass
2. Update documentation if needed
3. Follow the code style guidelines
4. Rebase on the latest main branch
5. Write a clear commit message

### PR Requirements
- Clear description of changes
- Reference any related issues
- Include screenshots for UI changes
- List any breaking changes
- Update CHANGELOG.md if needed

### Review Process
1. Automated checks must pass
2. Code review by maintainers
3. Address any feedback
4. Final approval and merge

## 🐛 Bug Reports

### Before Reporting
- Check existing issues
- Try to reproduce the bug
- Test on the latest version
- Gather relevant information

### Bug Report Template