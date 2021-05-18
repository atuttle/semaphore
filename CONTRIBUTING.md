# Contributing

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) All contributions are welcome! 💖

For the safety and wellbeing of everyone, please be aware that we will expect you to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## DO THIS FIRST 👷‍♂️ 🚧

Before you make any changes to the project, make sure the tests are running for you!

> 💥 🤬 **If the tests didn't pass before you made changes, how will you know if it was your changes that broke the tests?**

If you haven't already, you will need to install [CommandBox][commandbox] in order to run the tests.

```
$ git clone git@github.com:atuttle/semaphore.git
$ cd semaphore
$ box server start directory="tests" serverConfigFile="tests/server.json"
```

This gets the server running locally for you. It will need to be running whenever you want to run the tests. Now run the tests.

If you already have something using port 80, the tests won't work. You can either temporarily stop that service to run the tests, or you can submit a PR that makes our tests run on a nonstandard port. 😜

Once the server is running, if you prefer viewing the tests in a browser, they can be found at: http://localhost/runner.cfm

On the CLI:
 - `$ box testbox run` does a one-time run
 - `$ box testbox watch` will re-run the tests when relevant files are saved

I've also included a Makefile with some helpful aliases for managing the test server, and running tests

- `make test` will run the tests once, starting the server for you if it's not already running
- `make watch` will run the tests in watch mode, starting the server for you if it's not already running
- `make up` will start the server for you without running the tests in the CLI, useful if you want to run the tests in your browser
- `make down` will stop the server
- `make clean` will remove the server from your CommandBox server cache
- If it's easier for you to remember, `make start` is also an alias for `make up` and `make stop` is an alias for `make down`.

## Now, make your change

Once you're sure the tests are passing in your local environment with the latest code, you can go ahead and make your change. Be sure to use your own fork, and work in a branch (other than `main`). If you've never made a pull request before, don't worry, it's pretty easy and [this is a great and _free_ course to help you through it][makeapr].

## Recognition

This project uses [All Contributors][allcontribs] to recognize everyone that has helped create and maintain it. See [the documentation][allcontribs-bot-usage] on how to add yourself (but don't worry, we'll help you through it).

[commandbox]: https://www.ortussolutions.com/products/commandbox
[allcontribs]: https://allcontributors.org/
[allcontribs-bot-usage]: https://allcontributors.org/docs/en/bot/usage
[makeapr]: https://makeapullrequest.com
