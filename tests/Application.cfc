component{
	this.name = "flagService tests";
	// any other application.cfc stuff goes below:
	this.sessionManagement = false;

	// any mappings go here, we create one that points to the root called test.
	this.basePath = getDirectoryFromPath( getCurrentTemplatePath() ).replace('\\','/','ALL').replace('/tests/', '');
	this.mappings["/"] = this.basePath;
	this.mappings["/lib"] = this.basePath;
	this.mappings[ "/tests" ] = this.basePath & '/tests/';
	this.mappings[ "/testbox" ] = this.basePath & '/tests/testbox/';

}
