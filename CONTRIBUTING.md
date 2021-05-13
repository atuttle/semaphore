# Contributing

All contributions are welcome! 💖

For the safety and stress-reduction of everyone, please be aware that we will expect you to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## DO THIS FIRST 👷‍♂️ 🚧

Before you make any changes to the project, make sure the tests are running for you! **If the tests didn't pass before you made changes, how will you know if it was your changes that broke the tests?**

If you haven't already, install [CommandBox][commandbox].

```
$ git clone git@github.com:atuttle/cfml-feature-flags.git
$ cd cfml-feature-flags
$ box server start directory="tests" serverConfigFile="tests/server.json"
```

This gets the server running locally for you. Now run the tests.

If you prefer viewing the tests in a browser, they can be found at: http://localhost/runner.cfm

Or if you like tests on the CLI: `$ box testbox run` does a one-time run, or `$ box testbox watch` will re-run the tests when relevant files are saved.


## Recognition

This project uses [All Contributors][allcontribs] to recognize everyone that has helped create and maintain it. See [the documentation][allcontribs-bot-usage] on how to add yourself.

[commandbox]: https://www.ortussolutions.com/products/commandbox
[allcontribs]: https://allcontributors.org/
[allcontribs-bot-usage]: https://allcontributors.org/docs/en/bot/usage
