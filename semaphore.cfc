component {

	variables.flags = {};

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
		var flags = getAllFlags();
		if ( !structKeyExists(flags, arguments.flagId) ){
			return false;
		}
		var flag = flags[ flagId ];
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

		for ( var ruleGroup in arguments.flag.rules ){
			//all rules in a ruleGroup must match for the group to be true
			var groupAllTrue = true;
			for ( var rule in ruleGroup ){
				if ( evaluateRule( rule, arguments.userAttributes ) == false ){
					groupAllTrue = false;
					break;
				}
			}
			//if any ruleGroup is all true, then the flag is enabled
			if ( groupAllTrue ){
				return true;
			}
		}
		return false;
	}

	private boolean function evaluateRule( required struct rule, required struct userAttributes ){
		switch ( arguments.rule.type ){

			case 'everybody':
				return true;

			case 'nobody':
				return false;

			case '%':
				var crc = getUserRuleCRC( arguments.userAttributes, arguments.rule );
				return evalRuleOperator( crc, '<=', arguments.rule.percentage/100 );

			case 'filter':
				if ( !arguments.userAttributes.keyExists(arguments.rule.attribute) ){
					return false;
				}
				var userAttributeVal = arguments.userAttributes[ arguments.rule.attribute ];
				return evalRuleOperator( userAttributeVal, arguments.rule.operator, arguments.rule.comparator );

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
		if ( digits == '' ){
			/*
				it's theoretically possible for the MD5 to have no digits
				so let's handle that eventuality by subbing in zero's.
			*/
			digits = '0000';
		}
		var crc = '0.' & digits;
		return left(crc, 6);
	}

	private string function structToDeterministicString( required struct input ){
		var keys = structKeyArray( arguments.input );
		var data = [];
		arraySort( keys, 'text' );
		for ( var propName in keys ){
			data.append({ '#propName#': arguments.input[propName] });
		}
		return serializeJson( data );
	}

	private boolean function evalRuleOperator(required any userAttributeValue, required string operator, required any ruleValue){
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
				var ruleValueArray = ruleValue;
				try {
					if (!isArray(ruleValueArray)){
						ruleValueArray = listToArray(arguments.ruleValue);
					}
				} catch (any e){
					throw(type: "semaphore.invalidRuleValueInput", message: "Expected rule value to be an array or a string (list)");
				}
				return arrayFindNoCase(ruleValueArray, arguments.userAttributeValue) != 0;
			case 'has':
				var userAttributeValueArray = arguments.userAttributeValue;
				try {
					if (!isArray(userAttributeValueArray)){
						userAttributeValueArray = listToArray(userAttributeValueArray);
					}
				} catch (any e){
					throw(type: "semaphore.invalidUserAttributeValue", message: "Expected user attribute value to be an array or a string (list)");
				}
				return arrayFindNoCase(userAttributeValueArray, arguments.ruleValue) != 0;
			default:
				return false;
		}
	}

}
