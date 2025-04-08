# GymTracker

A Rails application for tracking your workouts and exercises.

## Testing

This project uses RSpec for testing. Tests are automatically run on every push and pull request through GitHub Actions.

### Running Tests Locally

To run the test suite locally:

```bash
bundle exec rspec
```

### Test Coverage

We use SimpleCov for test coverage reporting. After running the tests, you can find the coverage report in the `coverage` directory.

### Testing Guidelines

1. All new features should include corresponding tests
2. Run `bundle exec rspec` before committing changes to ensure nothing is broken
3. Maintain test coverage above 80%
4. System tests should use Capybara for feature testing

### Continuous Integration

GitHub Actions automatically runs our test suite on:
- Every push to main/master
- Every pull request to main/master

The workflow includes:
- Setting up Ruby and dependencies
- Setting up the test database
- Running the full test suite
- Generating test coverage reports

Make sure all tests pass before merging changes into the main branch.

<div text-align="center" justify-content="center">
  
  <img src="https://i.imgur.com/zVJFw0g.png" width="100%"/>  
  
  <hr>
  
  <img src="https://i.imgur.com/6b40TRI.png" alt="Summary" width="30%"/>
  <img src="https://i.imgur.com/fPi75Pz.png" alt="Summary" width="30%"/>
  <img src="https://i.imgur.com/GUIueOk.png" alt="Summary" width="30%"/>
  
  <hr>
  
  <img src="https://i.imgur.com/phCaJMM.png" width="100%"/>
  <img src="https://i.imgur.com/onlBmr3.png" width="100%"/>  
  <img src="https://i.imgur.com/ZqR3de5.png" width="100%"/> 
  <img src="https://i.imgur.com/D99sQVI.png" width="100%"/> 
  
</div>
