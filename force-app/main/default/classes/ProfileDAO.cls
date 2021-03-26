public class ProfileDAO
{
    public static Profile selectProfileByNameForTests(String profileName)
	{
		Profile aProfile = [SELECT Id
						  	  FROM Profile
						     WHERE name = :profileName
						     LIMIT 1];
		return aProfile;
	}

	public static Profile getNameFromId(String id) {
		Profile aProfile = [SELECT Name
						  	  FROM Profile
						     WHERE Id = :id
						     LIMIT 1];
		return aProfile;	
	}
}