# Semaphore
A minimalist Feature Flag engine for CFML apps

[![Tests](https://github.com/atuttle/semaphore/actions/workflows/main_tests.yml/badge.svg)](https://github.com/atuttle/semaphore/actions/workflows/main_tests.yml)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](CODE_OF_CONDUCT.md)

> #### Why?
> I created this because I got fed up trying to implement [FlagSmith](https://flagsmith.com) and [Split.io](https://www.split.io) in my app. They both assume that if you're using Java then you're willing/comfortable using Maven (strike 1), both of their docs barely cover SDK instantiation and I couldn't get either of them even simply on its feet let alone doing something useful (strike 2), and it's (mostly) just "if-statements", right? Why can't we host that ourselves? (strike 3)

> #### ⚠️ EARLY DAYS! DANGER! ⚠️
>
> I have only just begun working on this project and it's not really useful yet. Contributions are welcome, though!

### What IS included?

- Rules engine
- DSL (Domain Specific Language) for defining flags as data
- Methods for flag CRUD, and evaluation
- [![Tests](https://github.com/atuttle/semaphore/actions/workflows/main_tests.yml/badge.svg)](https://github.com/atuttle/semaphore/actions/workflows/main_tests.yml) Comprehensive test suite so that you know all of the above is trustworthy

### What's NOT included?

- Flag definition storage. Flag data is stored in-memory and it's up to you to bulk load it from your storage mechanism when your app starts up, and to save changes when they're made.
- GUI for creating, browsing, toggling, or otherwise modifying flags. You'll need to create your own, but I'll provide methods to hook in and do CRUD.

# Usage

1. Create a Semaphore instance. You only need one: cache it in Application or Server scope.
2. Load your flags at app startup: `semaphore.setAllFlags({ 'my_flag': {} });`
3. Wrap features thusly:

```js
if (semaphore.checkForUser( "my_flag", userAttributes )) {
	newImplementation();
} else {
	oldImplementation();
}
```

Based on the `userAttributes` and your flag definitions, `checkForUser()` returns true or false.

## User Attributes

`userAttributes` is a structure containing... anything you want. You'll want it to be flat (no nested structs), and contain all user-data and environment-data necessary to evaluate a flag. (Or to put it another way: include anything that you might want to use to create user segments.) For example:

```js
{
	userId: 42
	,userEmail: 'fordprefect@earth.pizza'
	,userGroup: 'towel'
	,betaOptIn: true
	,roles: ['security_admin','editor','writer','reader']
	,env: 'production'
}
```

I recommend storing this in the user session to eliminate repetitive data lookup and for easy reference.

## Flag Definitions

This is likely to change, but for now here's what they look like:

```js
{
	'example_percentage_flag': {
		name: 'Example Percentage Flag',
		description: 'This flag is only true for ~50% of the user population',
		active: true,
		rules: [
			{
				type: '%',
				percentage: 50
			}
		]
	}
	,'example_userId_flag': {
		name: 'Example UserId Flag',
		description: 'This flag is only true for userId 42',
		active: true,
		rules: [
			{
				type: 'attributeMath',
				attribute: 'userId',
				operator: '=',
				comparator: 42
			}
		]
	}
	,'example_email_flag': {
		name: 'Example Email Flag',
		description: 'This flag is only true for fordprefect@earth.pizza',
		active: true,
		baseState: false,
		rules: [
			{
				type: 'attributeMath',
				attribute: 'email',
				operator: 'in',
				comparator: ['fordprefect@earth.pizza']
			}
		]
	}
	,'example_inactive_flag': {
		name: 'Example Inactive Flag',
		description: 'This flag is false for everyone because it is inactive',
		active: false,
		baseState: false,
		rules: []
	}
}
```

### Flag Rule Types

- `%` "Percentage": A random % of users are in the active segment
- `attributeMath` "Attribute Math": You specify an attribute and a comparison (value and operator) and anyone who passes the comparison is in the active segment
- `nobodoy`: Flag is OFF for all users
- `everybody`: Flag is ON for all users
- More TBD? If you have ideas, [hit me up!](/atuttle/semaphore/issues)

# Why not just use config settings?

You could do that, sure. But the value proposition of feature flags is that they can be toggled independendtly of deploying code changes to your application, and often much more rapidly. They can take effect as quickly as you can update the flag state on your application.

(How you do that is left as an exercise for you. Once I've implemented it in my app I'll probably blog about how I did it and link to that blog post from here.)

ALSO, feature flags allow you to dynamically segment the user population. As we'll see below, I've already got support for %-based rollouts, as well as specific user-attribute and environment-attribute filtering.

# Contributing

Please see [Contributing.md](CONTRIBUTING.md)

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://adamtuttle.codes"><img src="https://avatars.githubusercontent.com/u/46990?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Adam Tuttle</b></sub></a><br /><a href="https://github.com/atuttle/semaphore/commits?author=atuttle" title="Code">💻</a> <a href="#content-atuttle" title="Content">🖋</a> <a href="https://github.com/atuttle/semaphore/commits?author=atuttle" title="Documentation">📖</a> <a href="#example-atuttle" title="Examples">💡</a></td>
    <td align="center"><a href="http://domwatson.codes"><img src="https://avatars.githubusercontent.com/u/471162?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Dominic Watson</b></sub></a><br /><a href="#tool-dominicwatson" title="Tools">🔧</a></td>
    <td align="center"><a href="http://blog.adamcameron.me/"><img src="https://avatars.githubusercontent.com/u/2041977?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Adam Cameron</b></sub></a><br /><a href="#ideas-adamcameron" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="http://sebduggan.com"><img src="https://avatars.githubusercontent.com/u/208398?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Seb Duggan</b></sub></a><br /><a href="https://github.com/atuttle/semaphore/issues?q=author%3Asebduggan" title="Bug reports">🐛</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
