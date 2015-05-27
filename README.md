User Setup Utils
===

###Description

Use this project to initialize your Salesforce Dev or Demo orgs with different users.
This package uses the https://randomuser.me/ API to generate fake data and even upload
chatter photos to the user profiles!

---
###Developers :

#### How to use the User Setup Utils :

Install the managed package with the following link:

https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1a000000E62q

Run the following code in the Developer Console:

```
usrsetup.UserSetupUtils.UserSetupParams myUserParams = new usrsetup.UserSetupUtils.UserSetupParams();
myUserParams.email = 'youremailaddress@yourdomain.com';
myUserParams.password = 'S0mePassw0rd!124';
myUserParams.profileName = 'Standard Platform User'; //A valid profile name
myUserParams.userType = 'MyUserType'; //A type that will be used for the user name
myUserParams.permissionSet = 'My_Permission_Set'; //A valid permission set API Name
myUserParams.totalUsers = 2; //Total number of users you want to create

usrsetup.UserSetupUtils.createUsers(myUserParams);
```

NOTE: If you're deploying this code directly to your org you'll need to remove the "usrsetup" namespace from the code sample above.

#### How to deploy the application using Ant :

1. Create/Update the sfdc-build.properties with your credentials.
2. Navigate to the build folder using the terminal or command prompt
3. If you're using **OS X** you can run the following command : `sh build.sh`
4. If you want to run the ant target directly use the following command : `ant deploy -DrunAllTests=false -DcheckOnly=false
