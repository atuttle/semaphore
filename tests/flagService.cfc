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

	public boolean function checkForUser( required string flagId, required struct userAttributes ){
		var flag = getAllFlags()[ flagId ];
		return checkFlagForUser( flag, arguments.userAttributes );
	}

	public boolean function checkFlagForUser( required struct flag, required struct userAttributes ){
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

	public struct function getAllFlags(){
		return variables.flags;
	}

	public struct function getAllFlagsForUser( required struct userAttributes ){
		var applicableFlagsForUser = {};
		var flagIds = variables.flags.keyArray();
		for ( var flagId in flagIds ){
			//default baseState to false
			param name="variables.flags['#flagId#'].baseState" default="false";
			if ( flagIsEnabledForUser( flagId, arguments.userAttributes ) ){
				applicableFlagsForUser[flagId] = !variables.flags[flagId].baseState;
			}else{
				applicableFlagsForUser[flagId] = variables.flags[flagId].baseState;
			}
		}
		return applicableFlagsForUser;
	}

	// ================== PRIVATES ==================

	private boolean function evaluateRule( required struct rule, required struct userAttributes ){
		switch ( arguments.rule.type ){

			case '%':
				var crc = getUserCRC( arguments.userAttributes );
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

	private numeric function getUserCRC( required struct userAttributes ){
		//todo: Is this even a safe thing to do?!
		var crc = '0.' & hash( serializeJson(arguments.userAttributes), 'md5' ).reReplaceNoCase('[a-z]', '', 'ALL');
		// writeDump(crc);
		return crc;
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
			default:
				return false;
		}
	}

}
