component extends="testbox.system.BaseSpec" {

	function run(){

		var flagService = createObject('lib.flagService');
		prepareMock( flagService );

		describe("flagService", function(){

			describe("::checkFlagForUser", function(){

				it("attributeMath defaults to false if the attribute isn't found", function(){
					var testUserAttributes = { };
					var testFlag = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '==', comparator: 'bar' } ] };
					var actual = flagService.checkFlagForUser(testFlag, testUserAttributes);
					expect( actual ).toBeFalse();
				});

				it("attributeMath `==` correctly", function(){
					var testUserAttributes = { foo: 'bar', found: false };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '==', comparator: 'bar' } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'found', operator: '==', comparator: true } ] };

					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = flagService.checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `!=` correctly", function(){
					var testUserAttributes = { foo: 'bar', found: false };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '!=', comparator: 'baz' } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'found', operator: '!=', comparator: false } ] };

					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = flagService.checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `>` correctly", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '>', comparator: 5 } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '>', comparator: 20 } ] };

					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = flagService.checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `>=` correctly (values ==)", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '>=', comparator: 10 } ] };
					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("attributeMath `<` correctly", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '<', comparator: 20 } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '<', comparator: 5 } ] };

					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = flagService.checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("attributeMath `<=` correctly (values ==)", function(){
					var testUserAttributes = { foo: 10 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: '<=', comparator: 10 } ] };
					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("attributeMath `in` correctly", function(){
					var testUserAttributes = { foo: 42 };
					var testFlagMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'foo', operator: 'in', comparator: [42] } ] };
					var testFlagNoMatch = { active: true, rules: [ { type: 'attributeMath', attribute: 'found', operator: 'in', comparator: [17] } ] };

					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					var actualNoMatch = flagService.checkFlagForUser(testFlagNoMatch, testUserAttributes);

					expect( actualMatch ).toBeTrue();
					expect( actualNoMatch ).toBeFalse();
				});

				it("% check returns true if CRC is <= desired value", function(){
					//mock the crc calculation
					flagService.$(method: "getUserCRC", returns: 0);

					var testUserAttributes = { foo: 42 };
					var testFlagMatch = { active: true, rules: [ { type: '%', percentage: 50 } ] };
					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

				it("% check returns false if CRC is > desired value", function(){
					//mock the crc calculation
					flagService.$(method: "getUserCRC", returns: 1);

					var testUserAttributes = { foo: 42 };
					var testFlag = { active: true, rules: [ { type: '%', percentage: 50 } ] };
					var actual = flagService.checkFlagForUser(testFlag, testUserAttributes);
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

					var actualMatch = flagService.checkFlagForUser(testFlagMatch, testUserAttributes);
					expect( actualMatch ).toBeTrue();
				});

			});

		});
	}

}