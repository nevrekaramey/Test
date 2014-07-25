@isTest
public class AuctionHelperTest{
    
    //Test method to check bulk creation of Auction Records
    static testMethod void test_insertAuctionWithoutBidInformation(){
        
        AuctionHelper aucHelper = new AuctionHelper();
        
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        Account acc = TestDataFactory.createAccountRecords();
        List<Auction__c> auctionList = new List<Auction__c>();
        
        System.runAs(auctionConsumer1){
            for(integer i=0;i<5000;i++){
                auctionList.add(new Auction__c(Name = 'Test Auction'+i, Declared_Value__c = 1000, Registered_Charity__c = acc.id,
                                Auction_Status__c = 'Active', ownerId = auctionConsumer1.id)
                );
            }
        
        //Start Test to insert records without bid
        Test.StartTest();
            insert auctionList;
        //End Test to insert records without bid
        Test.StopTest();   
        
            for(Auction__c a : auctionList){
                //Checking if the owner Id of the auction is same as the user creating the auction
                System.assertEquals(a.OwnerId, UserInfo.getUserId());
            }
        }
    }
    
    //Test to check if Auction owner can place bid while creating a Auction
    static testMethod void test_insertAuctionWithBidInformation(){
        
        AuctionHelper aucHelper = new AuctionHelper();
        
        User auctionConsumerUser1 = TestDataFactory.createUserRecords();
        Account acc = TestDataFactory.createAccountRecords();
        List<Auction__c> auctionList = new List<Auction__c>();
        
        System.runAs(auctionConsumerUser1){
            for(integer i=0;i<5000;i++){
                auctionList.add(new Auction__c(Name = 'Test Auction'+i, Declared_Value__c = 1000, Registered_Charity__c = acc.id,
                                            Auction_Status__c = 'Active', OwnerId = auctionConsumerUser1.id, Bid_Amount__c = 100));
            }
            
            try{
                //Start Test to insert records with bid
                Test.StartTest();
                    insert auctionList;
                //Stop Test to insert records with bid
                Test.StopTest();
            
                for(Auction__c a : auctionList){
                    //Checking if the owner Id of the auction is same as the user creating the auction
                    System.assertEquals(a.OwnerId, UserInfo.getUserId());
                }
            }catch(Exception e){
                 //Assert error message if auction owner places a bid while inserting auction
                 System.assert(e.getMessage()
                                .contains('Auction owner cannot place bid on the auction he is owning or on behalf of other users') 
                                ,e.getMessage());
            }
        }
    }
    
    //Testing Bid insert on Inactive Auctions
    static testMethod void test_insertBidOnInactiveAuction(){
        
        //Setting auction consumer1 user
        User auctionConsumerUser1 = TestDataFactory.createUserRecords();
        
        //Running as auction consumer1
        System.RunAs(auctionConsumerUser1){
            try{
                Auction__c auction = TestDataFactory.createAuctionWithNewAndBidStatus();
                //START TEST to insert bid record on Inactive Auction
                Test.startTest();
                insert auction;
                //STOP TEST to insert bid record on Inactive Auction
                Test.stopTest();
            }catch(Exception e){
                System.assert(e.getMessage()
                                .contains('Auction is inactive') 
                                ,e.getMessage());
            }
        }
    }
        
    //Testing updating Auction Bid information
    static testMethod void test_updateAuctionBidInformation(){
        
        AuctionHelper aucHelper = new AuctionHelper();
        
        User auctionConsumerUser1 = TestDataFactory.createUserRecords();
        Map<Id,Auction__c> oldAuctionValues = new Map<Id, Auction__c>();
        Map<Id,Auction__c> newAuctionValues = new Map<Id, Auction__c>();
        
        Auction__c auction;
        
        //Creating auction records as auction consumer 1
        System.RunAs(auctionConsumerUser1){
            auction = TestDataFactory.createAuctionWithoutBid();
            insert auction;
            //ADD OLD values to the map            
            oldAuctionValues.put(auction.id,auction);
            
            auction.Bid_Amount__c = 100;
            //ADD NEW updated values to the map      
            newAuctionValues.put(auction.id,auction);
        
            aucHelper.updateAuctionBidInformation(newAuctionValues, oldAuctionValues);  
        }
        
        User auctionConsumerUser2 = TestDataFactory.createBidUserRecords();
        
        //Updating auction records as auction consumer 2
        System.runAs(auctionConsumerUser2){
            auction.Bid_Amount__c = 200;   
            newAuctionValues.put(auction.id,auction);
            
            //START TEST to update auction information
            Test.startTest(); 
                aucHelper.updateAuctionBidInformation(newAuctionValues, oldAuctionValues);
            //STOP TEST to update auction information
            Test.stopTest();
        }    
    }
    
    //Testing Normalise Bid Name method 
    static testMethod void test_normaliseBidName(){
        AuctionHelper aucHelper = new AuctionHelper();
        Decimal bidAmount =  1000;
        String auctionName = 'Test Auction';
        String result;
        
        //START TEST to verify if Normalise Bid Name returns desired value
        Test.startTest();
            result = aucHelper.normaliseBidName(bidAmount, auctionName);
        //STOP TEST to verify if Normalise Bid Name returns desired value
        Test.stopTest();
        
        //POSITVE TEST
        System.assertEquals('$1000 for Test Auction', result);
        
        //NEGATIVE TEST
        System.assertNotEquals('$1000forTestAuction', result);
    }    
    
    //Manual test by setting owner and high bidder on auction
    static testMethod void test_UpdateAuctionRecords_Postive(){
        AuctionHelper aucHelper = new AuctionHelper();
        
        Account acc = TestDataFactory.createAccountRecords();
        
        List<Auction__c> auctionList = new List<Auction__c>();
        List<Auction__c> updateAuction = new List<Auction__c>();
        
        Map<Id, Auction__c> oldAuctionValues = new Map<Id, Auction__c>();
        Map<Id, Auction__c> newAuctionValues = new Map<Id, Auction__c>();
        
        //Assigning the user as USER1
        User auctionCreator = new User();
        auctionCreator.id = UserInfo.getUserId();
        
        auctionList.add(new Auction__c(Name = 'Test Auction', Declared_Value__c = 1000, Registered_Charity__c = acc.id,
                                Auction_Status__c = 'Active', OwnerId = auctionCreator.id));
        insert auctionList;
        
        //Adding old auction values to the map
        for(Auction__c a : auctionList){
            oldAuctionValues.put(a.id, a);
        }
        
        //Assigning the user as USER2
        User auctionConsumer1 = TestDataFactory.createConsumer1Records();
        
        //Updating old auction values
        for(Auction__c auction : auctionList){
            auction.Bid_Amount__c = 2000;
            auction.High_Bidder__c = auctionConsumer1.id; 
            updateAuction.add(auction);
        }
        
        //Adding values to be updated to the map
        for(Auction__c a : updateAuction){
            newAuctionValues.put(a.id, a);
        }
        
        //Fetching Bid Name and Bid Amount
        List<Bid__c> bidList = [Select Name, Bid_Amount__c From Bid__c Where ID IN: newAuctionValues.KeySet()];
        
        try{
            //START TEST to update auction and bid on the record
            Test.startTest();
                aucHelper.updateAuctionRecords(auctionList, newAuctionValues, oldAuctionValues);
                aucHelper.updateBidRecords(bidList, auctionList, newAuctionValues, false, oldAuctionValues);
            //STOP TEST to update auction and bid on the record
            Test.stopTest();
        }catch (Exception e) {
            //Assert Error Message
            System.assert(e.getMessage()
                           .contains('Auction owner cannot place bid on the auction he is owning or on behalf of other users')
                           ,e.getMessage());      
        }
   }
   
    //Same user cannot update bid record at the same time resulting in Duplicate ID error
    static testMethod void test_UpdateAuctionRecords_Negative(){
      AuctionHelper aucHelper = new AuctionHelper();
      Account acc = TestDataFactory.createAccountRecords();
        
      List<Auction__c> auctionList = new List<Auction__c>();
      List<Auction__c> updateAuction = new List<Auction__c>();
      
      Map<Id, Auction__c> oldAuctionValues = new Map<Id, Auction__c>();
      Map<Id, Auction__c> newAuctionValues = new Map<Id, Auction__c>();
      
      //Setting Auction to be updated as consumer1
      User auctionConusmer1 = TestDataFactory.createConsumer1Records();
      for(integer i=0;i<2;i++){
          auctionList.add(new Auction__c(Name = 'Test Auction'+i, Declared_Value__c = 1000, Registered_Charity__c = acc.id,
                                Auction_Status__c = 'Active', OwnerId = auctionConusmer1.id));
      }
      insert auctionList;
      
      //Adding old auction values to 'auctionValues' MAP
      for(Auction__c a : auctionList){
          oldAuctionValues.put(a.id, a);
      }
      
      //Setting Auction to be updated as consumer2
      User auctionConusmer2 = TestDataFactory.createUserRecords(); 
      
      //Updating old auction values
      for(Auction__c auction : auctionList){
          auction.Bid_Amount__c = 2000;
          auction.High_Bidder__c = auctionConusmer2.id; 
          updateAuction.add(auction);
      }
      
      //Adding new auction values to 'newAuctionValues' MAP
      for(Auction__c a : updateAuction){
          newAuctionValues.put(a.id, a);
      }
           
      try{
          //START TEST to update more than 1 record at same time by same user
          Test.startTest();
              aucHelper.updateAuctionRecords(auctionList, newAuctionValues, oldAuctionValues);
          //STOP TEST to update more than 1 record at same time by same user
          Test.stopTest();
      }catch (Exception e){
          //Assert Error Message
          System.assert( e.getMessage().contains('Duplicate id in list:'), e.getMessage());       
      }
    }
   
   //Test to to make sure Bid Amount is greater than the Reserve Amount if placed and the bid is placed on Active Auction
   static testMethod void test_checkBidAmountWithReserveAmount(){
       
       //Setting auction consumer1 user record
       User auctionConsumer1 = TestDataFactory.createUserRecords();
       
       Auction__c auctionWithoutBid;
       Auction__c auctionWithNewStatus;
       
       //Running as auction consumer1 
       System.RunAs(auctionConsumer1){
           //NEGATIVE TEST to make sure Bid Amount is greater than the Reserve Amount if placed
           auctionWithoutBid = TestDataFactory.createAuctionWithBidAndReserveAmount();
            
           ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithoutBid);
           AuctionOperation aucOperate = new AuctionOperation(Psc);
        
           PageReference pageRef = new PageReference('/a06/o');
           Test.setCurrentPage(pageRef);
           aucOperate.save();
        
           auctionWithNewStatus = TestDataFactory.createAuctionWithNewStatus();
           insert auctionWithNewStatus;
       }
       
       //Setting auction consumer2 user record
       User auctionConsumer2 = TestDataFactory.createBidUserRecords();
       Auction__c a = [Select Bid_Amount__c From Auction__c where Id =: auctionWithoutBid.id];
       
       //Running as auction consumer2
       System.RunAs(auctionConsumer2){
           a.bid_Amount__c = 100;
            
           //START TEST to check if Bid amount is greater or equal to reserve amount
           Test.startTest();
               ApexPages.StandardController sc1 = new ApexPages.StandardController(a);
               AuctionOperation aucOperate = new AuctionOperation(sc1);
            
               PageReference pageRef = new PageReference('/a06/o');
               Test.setCurrentPage(pageRef);
            
           try{
               aucOperate.placeOrUpdateBid();
           //STOP TEST to check if Bid amount is greater or equal to reserve amount
           Test.stopTest();
           }catch(Exception e){
                System.assert(e.getMessage().contains('Bid Amount needs to be equal or greater than Auction Reserve Amount')
                                            , e.getMessage());
            }
            
           try{
               auctionWithNewStatus.Bid_Amount__c = 1000;
               update auctionWithNewStatus;
           }catch(Exception e){
                System.assert(e.getMessage().contains('Auction is inactive'));
           }
       }   
   }
   
   //Test check deleting auction with associated bids
   static testMethod void test_deleteAuctionTest(){
       
       //Setting up Auction Consumer user1
       User auctionConsumer1 = TestDataFactory.createUserRecords();
        
       Auction__c auctionWithoutBid;
       Auction__c auctionWithNewStatus;
       
       //Running as Auction Consumer user1 not having access to delete the auction
       System.RunAs(auctionConsumer1){
           auctionWithoutBid = TestDataFactory.createAuctionWithBidAndReserveAmount();
            
           ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithoutBid);
           AuctionOperation aucOperate = new AuctionOperation(Psc);
        
           PageReference pageRef = new PageReference('/a06/o');
           Test.setCurrentPage(pageRef);
           aucOperate.save();
        
           auctionWithNewStatus = TestDataFactory.createAuctionWithNewStatus();
           insert auctionWithNewStatus;     
       }
       
       //Setting up Auction Consumer user2
       User auctionConsumer2 = TestDataFactory.createBidUserRecords();
       Auction__c a = [Select Bid_Amount__c From Auction__c where Id =: auctionWithoutBid.id];
       
       //Running as Auction Consumer user2 not having access to delete the auction
       System.RunAs(auctionConsumer2){
           try{
               //START NEGATIVE test to delete records with insufficient access rights
               delete auctionWithNewStatus;
           }catch(Exception e){
                System.assert(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY, insufficient access rights on object id'));
                //STOP NEGATIVE test to delete records with insufficient access rights
           }
       }
       
       //Setting up System Admin user
       User systemAdmin = TestDataFactory.createSysAdminUserRecords(); 
       Auction__c auctionDelete;
       
       //Running as auction conusmer user1
       System.RunAs(auctionConsumer1){
           auctionDelete= TestDataFactory.createAuctionWithBidAndReserveAmount();
           insert auctionDelete;
       }
       
       //Running as System Admin to delete records
       System.RunAs(systemAdmin){
           //START POSITIVE test to delete records with sufficient access rights
           Test.startTest();
               delete auctionDelete;
           //STOP POSITIVE test to delete records with sufficient access rights
           Test.stopTest();
       }  
   }
}