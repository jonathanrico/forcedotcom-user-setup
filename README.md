Force.com User Setup
===

###Description

Use this project to initialize your Salesforce org with different user types.
This package uses the RandomUserMe api to generate fake data and even upload
chatter photos to the user profiles!

---
###Developers :

#### Using the User Setup Utils :

```
UserSetupUtils.UserSetupParams myUserParams = new UserSetupUtils.UserSetupParams();
myUserParams.email = 'youremailaddress@yourdomain.com';
myUserParams.password = 'somepassword';
myUserParams.profileName = 'Standard User'; //A valid profile name
myUserParams.userType = 'MyUserType'; //A type that will be used for the user name
myUserParams.permissionSet = 'LMS_Publisher'; //A valid permission set API Name
myUserParams.totalUsers = 2; //Total number of users you want to create

UserSetupUtils.createUsers(myUserParams);
```

#### How to deploy the application using Ant :

1. Update the sfdc-build.properties with your credentials.
2. Navigate to the build folder using the terminal or command prompt
3. If you're using **OS X** you can run the following command : `sh build.sh`
4. If you want to run the ant target directly use the following command : `ant deploy -DrunAllTests=false -DcheckOnly=false
