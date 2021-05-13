# A minimalist Feature Flag engine for CFML apps

**Why?** I created this because I got fed up trying to implement [FlagSmith](https://flagsmith.com) and [Split.io](https://www.split.io) in my app. They both assume that if you're using Java then you're willing/comfortable using Maven (strike 1), both of their docs barely cover SDK instantiation and I couldn't get either of them even simply on its feet let alone doing something useful (strike 2), and it's (mostly) just "if-statements", right? Why can't we host that ourselves? (strike 3)

## ⚠️ EARLY DAYS! DANGER! ⚠️

I have only just begun working on this project and it's not really useful yet. Contributions are welcome, though!

### What's NOT included? (And may never be...)

- Flag definition storage. I'll consider providing a mechanism/callback for saving & loading flag definitions, but for now they're only in-memory.
- GUI for creating, browsing, toggling, or otherwise modifying flags. You'll need to create your own, but I'll provide methods to hook in and do so.

### What IS (or will be) included?

- Rules engine
- DSL (Domain Specific Language) for defining flags as data
- Methods for flag CRUD, and evaluation
- Comprehensive test suite so that you know all of the above is trustworthy

# How does it work?

Wrap features thusly:

```js
if (flagService.checkForUser( "my_flag", userAttributes )) {
	newImplementation();
} else {
	oldImplementation();
}
```

Based on the `userAttributes` and your flag definitions, `checkForUser()` returns true or false.

## User Attributes

`userAttributes` is a structure containing... anything you want. You'll want it to be flat (no nested properties), and contain all user-data and environment-data necessary to evaluate a flag. (Or to put it another way: include anything that you might want to use to create user segments.) For example:

```js
{
	userId: 42
	,userEmail: 'fordprefect@earth.pizza'
	,userGroup: 'towel'
	,betaOptIn: true
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
				operator: '>=',
				comparator: 50
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

- Percentage: A random % of users are in the active segment
- Attribute Math: You specify an attribute and a comparison (value and operator) and anyone who passes the comparison is in the active segment
- More to come?
