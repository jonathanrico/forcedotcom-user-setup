global class UserSetupUtils{

    global class UserSetupParams{
        global String email{get;set;}
        global String password{get;set;}
        global String profileName{get;set;}
        global String userType{get;set;}
        global String permissionSet{get;set;}
        global String roleName{get;set;}
        global String languageLocaleKey{get;set;}
        global String localeSidKey{get;set;}
        global String timeZoneSidKey{get;set;}
        global Integer totalUsers{get;set;}
    }

    global static List<User> createUsers(UserSetupParams params){

      List<User> newUsers = new List<User>();

      //Setup unique values
      Profile userProfile = [select id from Profile where Name = :params.profileName];
      List<UserRole> userRoles = new List<UserRole>();
      if(params.roleName != null){
          userRoles = [select id from UserRole where DeveloperName = :params.roleName];
      }

      List<Organization> organization = [select id from Organization limit 1];
      Id organizationId = organization.get(0).Id;
      String timeStamp = getTimeStamp();

      //Fetch random user data from randomuser api and store the goodness in collections
      List<Map<String, Object>> randomUsers = fetchRandomUserData(params.totalUsers);
      List<Blob> userImages = fetchUserImageBlobs(randomUsers);

      //Continue with user creation
      for(Integer i=0;i<params.totalUsers;i++){

          Map<String, Object> randomUserData = randomUsers.get(i);
          Map<String, Object> randomUserDataNames = (Map<String, Object>)randomUserData.get('name');

          User u = new User();
          String uniqueId = params.userType+''+i+''+timeStamp;
          u.FirstName = ((String)randomUserDataNames.get('first')).capitalize();
          u.LastName = ((String)randomUserDataNames.get('last')).capitalize();
          u.Title = ((String)randomUserDataNames.get('title')).capitalize();
          u.ProfileId = userProfile.Id;
          u.Email = params.email;
          u.Username= uniqueId+'@test'+organizationId+'.com';
          u.IsActive = true;
          u.Alias = getTimeStampForAlias()+i;
          u.CommunityNickname = uniqueId;
          u.TimeZoneSidKey = params.timeZoneSidKey!=null?params.timeZoneSidKey:'GMT';
          u.LocaleSidKey = params.localeSidKey!=null?params.localeSidKey:'en_US';
          u.EmailEncodingKey = 'ISO-8859-1';
          u.LanguageLocaleKey = params.languageLocaleKey!=null?params.languageLocaleKey:'en_US';
          u.UserPermissionsMobileUser = false;
          u.UserPermissionsSFContentUser = false;
          if(userRoles.size()>0){
              u.UserRoleId = userRoles.get(0).Id;
          }
          newUsers.add(u);
      }

      insert newUsers;

      //Set passwords
      for(User u : newUsers){
          System.setPassword(u.Id, params.password);
      }

      //Upload chatter pictures
      if(!Test.isRunningTest()){
          uploadImages(newUsers, userImages, null);
      }

      //Assign permission set
      Map<String,String> permissionSetAssignments = new Map<String,String>();

      if(params.permissionSet != null){
          List<PermissionSetAssignment> lpsa = new List<PermissionSetAssignment>();
          List<PermissionSet> lps = [select id from PermissionSet where Name = :params.permissionSet limit 1];

          if(lps.size()>0){
              for(User ouser : newUsers){
                  permissionSetAssignments.put(ouser.Id,lps.get(0).Id);
              }
              //Assignment permission sets in a future method to avoid MIXED-DML ops
              assignPermissionSets(permissionSetAssignments);
          }
      }

      return newUsers;
    }

    private static List<Map<String, Object>> fetchRandomUserData(Integer totalResults){
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://jrico-random-users.herokuapp.com/?nat=US&results='+totalResults);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String randomUserResponse = res.getBody();
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(randomUserResponse);
        List<Object> randomUserResults = (List<Object>)m.get('results');
        for(Object r : randomUserResults){
            Map<String, Object> userObject = (Map<String, Object>)r;
            Map<String, Object> userDetails = (Map<String,Object>) userObject.get('user');
            results.add(userDetails);
        }
        return results;
    }

    private static List<Blob> fetchUserImageBlobs(List<Map<String, Object>> results){
        List<Blob> userImages = new List<Blob>();
        for(Map<String, Object> userDetails : results){
            Map<String,Object> pictures = (Map<String,Object>) userDetails.get('picture');
            userImages.add(getImageBlob((String)pictures.get('medium')));
        }
        return userImages;
    }

    private static void uploadImages(List<User> users, List<Blob> userImages, String communityId){
        for(Integer i = 0;i < users.size();i++){
            ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(userImages[i],'image/jpg','UserPhoto');
            ConnectApi.Photo photoProfile = ConnectApi.ChatterUsers.setPhoto(communityId, users[i].Id, fileUpload);
        }
    }

    private static Blob getImageBlob(String imageUrl){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(imageUrl);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBodyAsBlob();
    }

    private static String getTimeStamp(){
        DateTime dtimenow = DateTime.now();
        String ts = dtimenow.day()+''+dtimenow.hour()+''+dtimenow.second()+''+dtimenow.millisecond();
        return ts;
    }

    private static String getTimeStampForAlias(){
        DateTime dtimenow = DateTime.now();
        String ts = dtimenow.second()+''+dtimenow.millisecond();
        return ts;
    }

    @future
    private static void assignPermissionSets(Map<String,String> permSetAssignmentsMap){
        List<PermissionSetAssignment> lpsa = new List<PermissionSetAssignment>();
        for(String uId : permSetAssignmentsMap.keySet()){
            PermissionSetAssignment opsa = new PermissionSetAssignment();
            opsa.AssigneeId = uId;
            opsa.PermissionSetId = permSetAssignmentsMap.get(uId);
            lpsa.add(opsa);
        }
        insert lpsa;
    }
}
