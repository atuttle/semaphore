component{
	this.name = "flagService tests";
	// any other application.cfc stuff goes below:
	this.sessionManagement = false;

	// any mappings go here, we create one that points to the root called test.
	this.basePath = getDirectoryFromPath( getCurrentTemplatePath() ).replace('\\','/','ALL').reverse().listDeleteAt(1,'/').listDeleteAt(1,'/').reverse();
	this.mappings["/lib"] = this.basePath;
	this.mappings[ "/tests" ] = this.basePath & '/tests';

}
