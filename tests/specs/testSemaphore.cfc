component extends="testbox.system.BaseSpec" {

	function run(){

		describe("semaphore", function(){

			describe("::checkForUser", function(){

				var semaphore = createObject('lib.semaphore');
				prepareMock( semaphore );

				it("finds the correct flag", function(){
					//mock the crc calculation to return a scenario we want to test
					semaphore.$(method: 'getAllFlags', returns: { 'flag_find_test': { green: 'best_color' }});
					semaphore.$(method: "checkFlagForUser", returns: true);
					var actual1 = semaphore.checkForUser('flag_find_test', {});
					expect( actual1 ).toBeTrue();

					semaphore.$(method: "checkFlagForUser", returns: false);
					var actual2 = semaphore.checkForUser('flag_find_test', {});
					expect( actual2 ).toBeFalse();
				});

			});

			describe("::checkFlagForUser", function(){

				var semaphore = createObject('lib.semaphore');
				prepareMock( semaphore );
				makePublic( semaphore, 'checkFlagForUser', 'pub_checkFlagForUser')

				it("filter defaults to false if the attribute isn't found", function(){
					var testUserAttributes = { };
					var testFlag = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '==', comparator: 'bar' } ] };
					var actual = semaphore.pub_checkFlagForUser(testFlag, testUserAttributes);
					expect( actual ).toBeFalse();
				});

				it("filter `==` correctly", function(){
					var testUserAttributes = { foo: 'bar', found: false };
					var testFlagMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '==', comparator: 'bar' } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'filter', attribute: 'found', operator: '==', comparator: true } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("filter `!=` correctly", function(){
					var testUserAttributes = { foo: 'bar', found: false };
					var testFlagMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '!=', comparator: 'baz' } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'filter', attribute: 'found', operator: '!=', comparator: false } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("filter `>` correctly", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '>', comparator: 5 } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '>', comparator: 20 } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("filter `>=` correctly (values ==)", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '>=', comparator: 10 } ] };
					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("filter `<` correctly", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '<', comparator: 20 } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '<', comparator: 5 } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("filter `<=` correctly (values ==)", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: '<=', comparator: 10 } ] };
					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("filter `in` correctly", function(){
					var testUserAttributes = { foo: 42 };
					var testFlagMatch = { active: true, rules: [ { type: 'filter', attribute: 'foo', operator: 'in', comparator: [42] } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'filter', attribute: 'found', operator: 'in', comparator: [17] } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("filter `has` correctly", function(){
					var testUserAttributes = { roles: ['pleb','admin','diety'] };
					var testFlagMatch = { active: true, rules: [ { type: 'filter', attribute: 'roles', operator: 'has', comparator: 'admin' } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'filter', attribute: 'roles', operator: 'has', comparator: 'pointy-haired-boss' } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("% check returns true if CRC is <= desired value", function(){
					//mock the crc calculation to return a scenario we want to test
					semaphore.$(method: "getUserRuleCRC", returns: 0);

					var testUserAttributes = { foo: 42 };
					var testFlagMatch = { active: true, rules: [ { type: '%', percentage: 50 } ] };
					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("% check returns false if CRC is > desired value", function(){
					//mock the crc calculation to return a scenario we want to test
					semaphore.$(method: "getUserRuleCRC", returns: 1);

					var testUserAttributes = { foo: 42 };
					var testFlag = { active: true, rules: [ { type: '%', percentage: 50 } ] };
					var actual = semaphore.pub_checkFlagForUser(testFlag, testUserAttributes);
					expect( actual ).toBeFalse();
				});

				it("returns true if only 1 rule matches", function(){
					var testUserAttributes = { id: 42, towel: true, improbability: .001 };
					var testFlagMatch = {
						active: true,
						rules: [
							{ type: 'filter', attribute: 'improbability', operator: '>', comparator: 0.005 },
							{ type: 'filter', attribute: 'id', operator: 'in', comparator: [23,19,'hut','hut','hike'] },
							{ type: 'filter', attribute: 'towel', operator: '==', comparator: true }
						]
					};

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("returns true if rule type is 'everybody'", function(){
					var testUserAttributes = { foo: 42 };
					var testFlag = { active: true, rules: [ { type: 'everybody' } ] };

					var actual = semaphore.pub_checkFlagForUser(testFlag, testUserAttributes);
					expect( actual ).toBeTrue();
				});

				it("returns false if rule type is 'nobody'", function(){
					var testUserAttributes = { foo: 42 };
					var testFlag = { active: true, rules: [ { type: 'nobody' } ] };

					var actual = semaphore.pub_checkFlagForUser(testFlag, testUserAttributes);
					expect( actual ).toBeFalse();
				});

			});

			describe("::getUserRuleCRC", function(){

				var semaphore = createObject('lib.semaphore');
				prepareMock( semaphore );
				makePublic( semaphore, 'getUserRuleCRC', 'pub_getUserRuleCRC');

				it("returns a known value", function(){
					var crcActual = semaphore.pub_getUserRuleCRC( { user: "adam", id: 42 }, { awesome: true } );
					expect( crcActual ).toBe( 0.3333 );
				});

				it("returns different values for similar inputs (json-inversion check)", function(){
					var crcActual1 = semaphore.pub_getUserRuleCRC( { foo: "x", bar: "y" }, { awesome: true } );
					var crcActual2 = semaphore.pub_getUserRuleCRC( { foo: "y", bar: "x" }, { awesome: true } );
					expect( crcActual1 ).notToBe( crcActual2 );
				});

			});

			describe("::evalRuleOperator", function(){

				var semaphore = createObject('lib.semaphore');
				prepareMock( semaphore );
				makePublic( semaphore, 'evalRuleOperator', 'pub_evalRuleOperator');

				it("correctly implements == and =", function(){
					var actual1 = semaphore.pub_evalRuleOperator('a', '=', 'a');
					var actual2 = semaphore.pub_evalRuleOperator('a', '=', 'b');
					var actual3 = semaphore.pub_evalRuleOperator('b', '=', 'b');
					var actual4 = semaphore.pub_evalRuleOperator('a', '==', 'a');
					var actual5 = semaphore.pub_evalRuleOperator('a', '==', 'b');
					var actual6 = semaphore.pub_evalRuleOperator('b', '==', 'b');
					expect(actual1).toBeTrue();
					expect(actual2).toBeFalse();
					expect(actual3).toBeTrue();
					expect(actual4).toBeTrue();
					expect(actual5).toBeFalse();
					expect(actual6).toBeTrue();
				});

				it("correctly implements !=", function(){
					var actual1 = semaphore.pub_evalRuleOperator('a', '!=', 'a');
					var actual2 = semaphore.pub_evalRuleOperator('a', '!=', 'b');
					expect(actual1).toBeFalse();
					expect(actual2).toBeTrue();
				});

				it("correctly implements <", function(){
					var actual1 = semaphore.pub_evalRuleOperator(7, '<', 12);
					var actual2 = semaphore.pub_evalRuleOperator(7, '<', 7);
					var actual3 = semaphore.pub_evalRuleOperator(7, '<', 2);
					expect(actual1).toBeTrue();
					expect(actual2).toBeFalse();
					expect(actual3).toBeFalse();
				});

				it("correctly implements <=", function(){
					var actual1 = semaphore.pub_evalRuleOperator(7, '<=', 12);
					var actual2 = semaphore.pub_evalRuleOperator(7, '<=', 7);
					var actual3 = semaphore.pub_evalRuleOperator(7, '<=', 2);
					expect(actual1).toBeTrue();
					expect(actual2).toBeTrue();
					expect(actual3).toBeFalse();
				});

				it("correctly implements >", function(){
					var actual1 = semaphore.pub_evalRuleOperator(7, '>', 12);
					var actual2 = semaphore.pub_evalRuleOperator(7, '>', 7);
					var actual3 = semaphore.pub_evalRuleOperator(7, '>', 2);
					expect(actual1).toBeFalse();
					expect(actual2).toBeFalse();
					expect(actual3).toBeTrue();
				});

				it("correctly implements >=", function(){
					var actual1 = semaphore.pub_evalRuleOperator(7, '>=', 12);
					var actual2 = semaphore.pub_evalRuleOperator(7, '>=', 7);
					var actual3 = semaphore.pub_evalRuleOperator(7, '>=', 2);
					expect(actual1).toBeFalse();
					expect(actual2).toBeTrue();
					expect(actual3).toBeTrue();
				});

				it("correctly implements in", function(){
					var actual1 = semaphore.pub_evalRuleOperator('foo', 'in', ['a','foo']);
					var actual2 = semaphore.pub_evalRuleOperator('foo', 'in', ['a','b','c']);
					expect(actual1).toBeTrue();
					expect(actual2).toBeFalse();
				});

				it("correctly implements has", function(){
					var actual1 = semaphore.pub_evalRuleOperator(['a','foo'], 'has', 'foo');
					var actual2 = semaphore.pub_evalRuleOperator(['a','b','c'], 'has', 'foo');
					expect(actual1).toBeTrue();
					expect(actual2).toBeFalse();
				});

			});

			describe("::setAllFlags", function(){

				var semaphore = createObject('lib.semaphore');
				prepareMock( semaphore );

				it("sets the entire flags variable", function(){
					var dummyFlags = { 'foo': 42, 'bar': 'baz' };
					semaphore.setAllFlags(dummyFlags);
					var actualFlags = semaphore.$getProperty( name: 'flags', scope: 'variables' );
					expect( actualFlags ).toBe( dummyFlags );
				});

			});

			describe("::getAllFlags", function(){

				var semaphore = createObject('lib.semaphore');
				prepareMock( semaphore );

				it("gets the entire flags variable", function(){
					var dummyFlags = { 'alexander': 'hamilton' };
					semaphore.$property( propertyName: 'flags', propertyScope: 'variables', mock: dummyFlags );
					var actual = semaphore.getAllFlags();
					debug( actual );
					expect( actual ).toBe( dummyFlags );
				});

			});

			describe("::setFlag", function(){

				var semaphore = createObject('lib.semaphore');
				prepareMock( semaphore );

				it("sets one flag", function(){
					var dummyFlag = { 'foo': 42 };
					semaphore.setFlag('dummy', dummyFlag);

					var actualFlags = semaphore.$getProperty( name: 'flags', scope: 'variables' );
					expect( actualFlags.keyExists('dummy') ).toBeTrue();
					expect( actualFlags['dummy'] ).toBe( dummyFlag );
				});

			});

			describe("::getFlag", function(){

				var semaphore = createObject('lib.semaphore');
				prepareMock( semaphore );

				it("gets one flag", function(){
					var dummyFlags = { 'burr': {first: 'aaron'}, 'mulligan': { first: 'hercules' } };
					semaphore.$property( propertyName: 'flags', propertyScope: 'variables', mock: dummyFlags );
					var actual = semaphore.getFlag( 'mulligan' );
					expect( actual ).toBe( dummyFlags.mulligan );
				});

			});

		});
	}

}
