@isTest
public class TestDataFactory {
    
    public static User createConsumer1Records() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Charity Auctions Consumer']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='CharityAuctionConsumer1@testorg.com'
                          );
        insert u;
        return u;                 
    }
    //Creating a Test User Record
    public static User createUserRecords() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Charity Auctions Consumer']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='CharityAuctionConsumer501@testorg.com'
                          );
        insert u;
        return u;                 
    }
    
    public static User createBidUserRecords() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Charity Auctions Consumer']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='CharityAuctionConsumer502@testorg.com'
                          );
        insert u;
        
        return u;                 
    }
    
    public static User createSysAdminUserRecords() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='CharitySystemAdministrator@testorg.com'
                          );
        insert u;
        
        return u;                 
    }
    
    public static User createCharityAuctionsAdministratorUserRecords() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Charity Auctions Administrator']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='CharityAuctionAdministrator@testorg.com'
                          );
        insert u;
        
        return u;                 
    }
    
      public static User createAuctionConsumer3Record() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Charity Auctions Consumer']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='CharityAuctionConsumer3@testorg.com'
                          );
        insert u;
        
        return u;                 
    }
    //Creating Auction Charity Accounts
    public static Account createAccountRecords(){
        Account acc = new Account(Name = 'Test Account', Registered_Charity__c = true);
        insert acc;
        return acc;
    }
    
    //Creating Auction Without Bid Records
    public static Auction__c createAuctionWithoutBid(){
        
        Auction__c auctionWithoutBid =
                    new Auction__c(Name = 'Test Auction', Declared_Value__c = 1000, Registered_Charity__c = createAccountRecords().id,
                                Auction_Status__c = 'Active');
        return auctionWithoutBid;
    }
    
    //Creating Auction With Bid Records
    public static Auction__c createAuctionWithBid(){
        Auction__c auctionWithBid =
                    new Auction__c(Name = 'Test Auction', Declared_Value__c = 1000, Registered_Charity__c = createAccountRecords().id,
                                Auction_Status__c = 'Active', Bid_Amount__c=1000);
        return auctionWithBid;
    }
    
    //Creating Auction With Bid and Reserve Amount Records
    public static Auction__c createAuctionWithBidAndReserveAmount(){
        Auction__c auctionWithBidAndReserveAmount =
                    new Auction__c(Name = 'Test Auction', Declared_Value__c = 1000, Registered_Charity__c = createAccountRecords().id,
                                    Auction_Status__c = 'Active', Reserve_Amount__c = 500);
        return auctionWithBidAndReserveAmount;
    }
    
    public static Auction__c createAuctionNewWithoutBid(){
       Auction__c auctionNewWithoutBid = 
                   new Auction__c(Name = 'Test Auction', Declared_Value__c = 1000, Registered_Charity__c = createAccountRecords().id,
                                    Auction_Status__c = 'New');                 
       return auctionNewWithoutBid;
    }
    
     public static Auction__c createAuctionWithNewAndBidStatus(){
       Auction__c auctionWithNewStatusAndBid = 
                   new Auction__c(Name = 'Test Auction', Declared_Value__c = 1000, Registered_Charity__c = createAccountRecords().id,
                                Auction_Status__c = 'New',Bid_Amount__c = 1000);            
       return auctionWithNewStatusAndBid;
    }
    
    public static Auction__c createAuctionWithNewStatus(){
       Auction__c auctionWithNewStatus = 
                   new Auction__c(Name = 'Test Auction', Declared_Value__c = 1000, Registered_Charity__c = createAccountRecords().id,
                                Auction_Status__c = 'New');            
       return auctionWithNewStatus;
    }
   
    public static Auction__c createAuctionWithEndedStatus(){
       Auction__c auctionWithEndedStatus = 
                   new Auction__c(Name = 'Test Auction', Declared_Value__c = 1000, Registered_Charity__c = createAccountRecords().id,
                                    Auction_Status__c = 'Ended');                 
       return auctionWithEndedStatus;
    }
}