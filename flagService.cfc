component
{

	variables.flags = {};

	/* some example flags:
		variables.flags = {
			'example_crc_flag': {
				name: 'Example CRC Flag',
				description: 'This flag is only true for ~50% of the user population (assuming hash(serializeJson()) is evenly distributed)',
				active: true,
				baseState: false,
				rules: [
					{
						//$CRC is intended to be a numerical checksum of the userAttributes map, value between 0-1
						//... to enable % of users who get the flag
						type: '$CRC',
						operator: '>=',
						comparator: 0.5
					}
				]
			}
			,'example_userId_flag': {
				name: 'Example UserId Flag',
				description: 'This flag is only true for userId 42',
				active: true,
				baseState: false,
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
				description: 'This flag is only true for adam@alumniq or crump@alumniq',
				active: true,
				baseState: false,
				rules: [
					{
						type: 'attributeMath',
						attribute: 'email',
						operator: 'in',
						comparator: ['adam@alumniq.com','crump@alumniq.com']
					}
				]
			}
			,'example_inverted_flag': {
				name: 'Example Inverted Flag',
				description: 'This flag is true by default and gets toggled to false for matches',
				active: true,
				baseState: false,
				rules: [
					{
						type: '$CRC',
						operator: '>',
						comparator: 2
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
		};
	*/

	public struct function getAllFlags(){
		return variables.flags;
	}

	public void function setAllFlags( required struct flags ){
		variables.flags = arguments.flags;
	}

	public struct function getFlag( required string flagId ){
		return variables.flags[ arguments.flagId ];
	}

	public void function setFlag( required string flagId, required struct flag ){
		variables.flags[ arguments.flagId ] = arguments.flag;
	}

	public boolean function checkForUser( required string flagId, required struct userAttributes ){
		var flag = getAllFlags()[ flagId ];
		return checkFlagForUser( flag, arguments.userAttributes );
	}

	public struct function getAllFlagsForUser( required struct userAttributes ){
		var applicableFlagsForUser = {};
		var flagIds = variables.flags.keyArray();
		for ( var flagId in flagIds ){
			param name="variables.flags['#flagId#'].baseState" default="false";
			if ( checkForUser( flagId, arguments.userAttributes ) ) {
				applicableFlagsForUser[flagId] = !variables.flags[flagId].baseState;
			} else {
				applicableFlagsForUser[flagId] = variables.flags[flagId].baseState;
			}
		}
		return applicableFlagsForUser;
	}

	// ================== PRIVATES ==================

	private boolean function checkFlagForUser( required struct flag, required struct userAttributes ){
		//todo: caching will speed this up
		if ( arguments.flag.active == false ){
			return false;
		}
		//return true at first matching rule, no need to check them all
		for ( var rule in arguments.flag.rules ){
			if ( evaluateRule( rule, arguments.userAttributes ) ){
				return true;
			}
		}
		return false;
	}

	private boolean function evaluateRule( required struct rule, required struct userAttributes ){
		switch ( arguments.rule.type ){

			case '%':
				var crc = getUserRuleCRC( arguments.userAttributes, arguments.rule );
				return ruleMathIsTrue( crc, '<=', arguments.rule.percentage/100 );

			case 'attributeMath':
				if ( !arguments.userAttributes.keyExists(arguments.rule.attribute) ){
					return false;
				}
				var userAttributeVal = arguments.userAttributes[ arguments.rule.attribute ];
				return ruleMathIsTrue( userAttributeVal, arguments.rule.operator, arguments.rule.comparator );

			default:
				return false;
		}
	}

	private numeric function getUserRuleCRC( required struct userAttributes, required struct rule ){
		/*
			This is what I'm doing.
			Is it safe? I don't see why not.
			Is it "right"? Probably not.
			Does it work? Seems like it to me!

			GOAL:
				Given a struct with some data, convert that to a numeric value
				between 0-1 in a deterministic manner.

			APPROACH:
				- We want deterministic JSON of userAttributes but can't count on CFML engines to give it to us.
				- To make it deterministic, create an array in sorted-struct-key-order of each k/v pair
				- serialize that array to JSON
				- prepend the deterministic-json of the rule (so that the same users don't get selected for every % rule)
				- MD5 hash the resulting string to create a value with widely distributed numeric range
				- then strip out all letters, leaving some numeric value
				- then prepend "0." to get it to be somewhere between 0 and 1
				- run a left(6) on it to guarantee no more than 4 digits after the decimal place

			This appears to generate a sufficiently random, widely distributed range
			of numbers between 0-1. Collisions are possible, but that should be true
			of any solution, and two users having the same CRC is not actually a
			problem for our purposes. We don't need a unique number for all users, we
			just need to be able to segment them consistently.
		*/

		var userAttrsString = structToDeterministicString( arguments.userAttributes );
		var ruleString = structToDeterministicString( arguments.rule );
		var mashup = ruleString & userAttrsString;
		var hashed = hash( mashup );
		var digits = hashed.reReplaceNoCase('[a-z]', '', 'ALL');
		var crc = '0.' & digits;
		return left(crc, 6);
	}

	private string function structToDeterministicString( required struct in ){
		var keys = structKeyArray( arguments.in );
		var data = [];
		arraySort( keys, 'text' );
		for ( var propName in keys ){
			data.append({ '#propName#': arguments.in[propName] });
		}
		return serializeJson( data );
	}

	private boolean function ruleMathIsTrue(required any userAttributeValue, required string operator, required any ruleValue){
		switch (arguments.operator){
			case '=':
			case '==':
				return arguments.userAttributeValue == arguments.ruleValue;
			case '!=':
				return arguments.userAttributeValue != arguments.ruleValue;
			case '<':
				return arguments.userAttributeValue < arguments.ruleValue;
			case '<=':
				return arguments.userAttributeValue <= arguments.ruleValue;
			case '>':
				return arguments.userAttributeValue > arguments.ruleValue;
			case '>=':
				return arguments.userAttributeValue >= arguments.ruleValue;
			case 'in':
				return arrayFindNoCase(arguments.ruleValue, arguments.userAttributeValue) != 0;
			case 'has':
				return arrayFindNoCase(arguments.userAttributeValue, arguments.ruleValue) != 0;
			default:
				return false;
		}
	}

}
