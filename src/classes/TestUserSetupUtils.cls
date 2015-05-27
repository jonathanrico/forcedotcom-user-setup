@IsTest
private class TestUserSetupUtils{

    static testMethod void testUserCreation(){

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('RandomUserMeResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();

           UserSetupUtils.UserSetupParams myUserParams = new UserSetupUtils.UserSetupParams();
           myUserParams.email = 'randomemail@testdomain123.com';
           myUserParams.password = 'S0meRandom!Pwd1';
           myUserParams.profileName = 'Standard User'; //A valid profile name
           myUserParams.userType = 'MyUserType'; //A type that will be used for the user name
           myUserParams.totalUsers = 2; //Total number of users you want to create

           UserSetupUtils.createUsers(myUserParams);

           List<User> testUsers = [select id from User where email = 'randomemail@testdomain123.com'];
           System.assert(testUsers.size()>0);

        Test.stopTest();

    }

}
