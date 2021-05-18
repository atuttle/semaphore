component extends="testbox.system.BaseSpec" {

	function run(){

		var semaphore = createObject('lib.semaphore');
		prepareMock( semaphore );

		describe("semaphore", function(){

			describe("::checkFlagForUser", function(){

				makePublic( semaphore, 'checkFlagForUser', 'pub_checkFlagForUser')

				it("attributeMath defaults to false if the attribute isn't found", function(){
					var testUserAttributes = { };
					var testFlag = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '==', comparator: 'bar' } ] };
					var actual = semaphore.pub_checkFlagForUser(testFlag, testUserAttributes);
					expect( actual ).toBeFalse();
				});

				it("attributeMath `==` correctly", function(){
					var testUserAttributes = { foo: 'bar', found: false };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '==', comparator: 'bar' } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'found', operator: '==', comparator: true } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `!=` correctly", function(){
					var testUserAttributes = { foo: 'bar', found: false };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '!=', comparator: 'baz' } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'found', operator: '!=', comparator: false } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `>` correctly", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '>', comparator: 5 } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '>', comparator: 20 } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `>=` correctly (values ==)", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '>=', comparator: 10 } ] };
					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("attributeMath `<` correctly", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '<', comparator: 20 } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '<', comparator: 5 } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `<=` correctly (values ==)", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '<=', comparator: 10 } ] };
					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("attributeMath `in` correctly", function(){
					var testUserAttributes = { foo: 42 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: 'in', comparator: [42] } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'found', operator: 'in', comparator: [17] } ] };

					var actualMatch = semaphore.pub_checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = semaphore.pub_checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `has` correctly", function(){
					var testUserAttributes = { roles: ['pleb','admin','diety'] };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'roles', operator: 'has', comparator: 'admin' } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'roles', operator: 'has', comparator: 'pointy-haired-boss' } ] };

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
							{ type: 'attributeMath', attribute: 'improbability', operator: '>', comparator: 0.005 },
							{ type: 'attributeMath', attribute: 'id', operator: 'in', comparator: [23,19,'hut','hut','hike'] },
							{ type: 'attributeMath', attribute: 'towel', operator: '==', comparator: true }
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

		});
	}

}
