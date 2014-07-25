@isTest
public class AuctionOperationTest{

    static testMethod void test_AuctionSaveTest(){
        
        //Setting auction consumer1 user
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        
        //Running as auction consumer1
        System.RunAs(auctionConsumer1){
        
            //Auction Record for Positive Test to check to make sure Auctions get created without auction owner creating/placing the bids
            Auction__c auctionWithoutBid = TestDataFactory.createAuctionWithoutBid();
                                
            //Auction Record for Negative Test to check to make sure Auction owner does not bid on the auction
            Auction__c auctionWithBid = TestDataFactory.createAuctionWithBid();
            
            //STARTING TEST
            Test.startTest();
                //START POSITIVE TEST to check to make sure Auctions get created without auction owner creating/placing the bids
                ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithoutBid);
                AuctionOperation aucOperate = new AuctionOperation(Psc);
        
                PageReference pageRef = new PageReference('/a06/o');
                Test.setCurrentPage(pageRef);
                aucOperate.save();
                //END POSITVE TEST
                
                //START NEGATIVE TEST to check to make sure Auction owner does not bid on the auction
                ApexPages.StandardController Nsc = new ApexPages.StandardController(auctionWithBid);
                AuctionOperation aucOperate1 = new AuctionOperation(Nsc);
        
            //try catch block to catch the exception thrown when Auction is created with bid by auction owner
            try{
                aucOperate1.save();
            //STOPPING TEST
            Test.stopTest();
             //END NEGATIVE TEST
            }catch(Exception e){
                System.assert(e.getMessage()
                               .contains('Auction owner cannot place bid on the auction he is owning or on behalf of other users'));
            }
        }
    }
    
    //Test to check if auction bids are placed correctly
    static testMethod void test_AuctionPlaceOrUpdateBidTest(){
        
        //Setting auction consumer1 user
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        Auction__c auctionWithoutBid;
        
        //Running as auction consumer1
        System.RunAs(auctionConsumer1){
            auctionWithoutBid = TestDataFactory.createAuctionWithoutBid();
                                
            ApexPages.StandardController sc = new ApexPages.StandardController(auctionWithoutBid);
            AuctionOperation aucOperate = new AuctionOperation(sc);
            aucOperate.save();
        }
        
        //Setting auction consumer2 user
        User auctionConsumer2 = TestDataFactory.createBidUserRecords();
        
        Auction__c a = [Select Bid_Amount__c From Auction__c where Id =: auctionWithoutBid.id];
        
        //Running as auction consumer2 user
        System.RunAs(auctionConsumer2){
            a.bid_Amount__c = 1000;
            
            ApexPages.StandardController sc1 = new ApexPages.StandardController(a);
            AuctionOperation aucOperate = new AuctionOperation(sc1);
            
            PageReference pageRef = new PageReference('/a06/o');
            Test.setCurrentPage(pageRef);
            aucOperate.placeOrUpdateBid();
        }
        
        //Setting auction consumer3 user
        User auctionConsumer3 = TestDataFactory.createAuctionConsumer3Record();
        
        Auction__c a1 = [Select Bid_Amount__c From Auction__c where Id =: auctionWithoutBid.id];
        
        //Running as auction consumer3
        System.RunAs(auctionConsumer3){
            a1.bid_Amount__c = 2000;
            
            ApexPages.StandardController sc1 = new ApexPages.StandardController(a1);
            AuctionOperation aucOperate = new AuctionOperation(sc1);
            
            PageReference pageRef = new PageReference('/a06/o');
            Test.setCurrentPage(pageRef);
            aucOperate.placeOrUpdateBid();
            
            a1.bid_Amount__c = 3000;
            aucOperate.placeOrUpdateBid();
        }              
    }
    
    //Test to check if auction is placed in 'ACTIVE' status
    static testMethod void test_startAuctionTest(){
        
        //Setting auction consumer1 user
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        
        Auction__c auctionWithoutBid;
        Auction__c auctionWithBid;
        
        //Running as auction consumer1 user
        System.RunAs(auctionConsumer1){
            //POSITIVE TEST to check to make sure Auction owner does not bid on the auction while starting the aution
            auctionWithoutBid = TestDataFactory.createAuctionWithoutBid();
            
            //NEGATIVE TEST to check to make sure Auction owner does not bid on the auction while starting the aution
            auctionWithBid = TestDataFactory.createAuctionWithBid();
            
            //START POSITIVE TEST to check to make sure Auctions get created without auction owner creating/placing the bids 
            Test.startTest();                
            ApexPages.StandardController sc = new ApexPages.StandardController(auctionWithoutBid);
            AuctionOperation aucOperate = new AuctionOperation(sc);
            aucOperate.startAuction();
            
            //Checking if auction status is set to 'ACTIVE' status
            Auction__c a = [Select Auction_Status__c From Auction__c Where Id =:auctionWithoutBid.id];
            System.assertEquals('Active', a.Auction_Status__c);
            //END POSITIVE TEST
            
            //START NEGATIVE TEST to check to make sure Auctions get created without auction owner creating/placing the bids                    
            ApexPages.StandardController sc1 = new ApexPages.StandardController(auctionWithBid);
            AuctionOperation aucOperate1 = new AuctionOperation(sc1);
            
            try{
                aucOperate1.startAuction();
                Test.stopTest();
                //END TEST
            }catch(Exception e){
                System.assert(e.getMessage()
                               .contains('Auction owner cannot place bid on the auction he is owning or on behalf of other users'));
            }
        }
    }
    
    //Testing standard cancel button
    static testMethod void test_cancelAuctionTest(){
        
        Auction__c auction = TestDataFactory.createAuctionWithoutBid();
                   
        ApexPages.StandardController Psc = new ApexPages.StandardController(auction);
        AuctionOperation aucOperate = new AuctionOperation(Psc);
        
        PageReference pageRef = new PageReference('/a06/o');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        aucOperate.cancelAuction();
        Test.stopTest();
    }
    
    //Testing end auction button
    static testMethod void test_endAuctionTest(){
        
        //Setting auction consumer1 user 
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        
        Auction__c auctionWithoutBid;
        Auction__c auctionWithBidAndReserveAmount;
        
        //Creating the Auction as charity consumer
        System.RunAs(auctionConsumer1){
            auctionWithoutBid = TestDataFactory.createAuctionWithoutBid();
                   
            ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithoutBid);
            AuctionOperation aucOperate = new AuctionOperation(Psc);
            aucOperate.save();
            
            //calling end auction method
            aucOperate.endAuction();
            
            //Creating Auction with Bid and Reserve Amount
            auctionWithBidAndReserveAmount = TestDataFactory.createAuctionWithBidAndReserveAmount();
                   
            ApexPages.StandardController Psc1 = new ApexPages.StandardController(auctionWithBidAndReserveAmount);
            AuctionOperation aucOperate1 = new AuctionOperation(Psc1);
            aucOperate1.save();
        }
        
        //Setting auction consumer2 user 
        User auctionConsumer2 = TestDataFactory.createAuctionConsumer3Record();
        Auction__c auction;
        
        //Placing Bid on the Auction by charity consumer2
        System.RunAs(auctionConsumer2){
            auction = [Select Auction_Status__c, Bid_Amount__c From Auction__c Where Id =:auctionWithBidAndReserveAmount.id];
            auction.Bid_Amount__c = 400;
            ApexPages.StandardController Psc1 = new ApexPages.StandardController(auction);
            AuctionOperation aucOperate1 = new AuctionOperation(Psc1);
            aucOperate1.placeOrUpdateBid();
                   
            //Running as auction consumer1 user 
            System.RunAs(auctionConsumer1){
                aucOperate1.endAuction();
                System.assertEquals('Ended', auction.Auction_Status__c);
            }
        }
    }
    
    //Testing placeOrUpdate bid button visibility
    static testMethod void test_getAuctionStatusTest(){
        
        //Setting auction consumer1 user 
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        
        Auction__c auctionWithoutBid;
        Auction__c auctionNewWithoutBid;
        Auction__c auctionWithEndStatus;
        AuctionOperation aucOperate;
        
        //Running as auction consumer1 user 
        System.RunAs(auctionConsumer1){
            auctionWithoutBid = TestDataFactory.createAuctionWithoutBid();
                   
            ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithoutBid);
            aucOperate = new AuctionOperation(Psc);
            aucOperate.save();
            auctionNewWithoutBid = TestDataFactory.createAuctionNewWithoutBid();
        }
        
        //Setting auction consumer2 user 
        User auctionConsumer2 = TestDataFactory.createBidUserRecords();
         
         //Running as auction consumer2 user 
        System.RunAs(auctionConsumer2){
            //Need to return true after meeting the first condition
          System.assert(aucOperate.getAuctionStatus());
        }
        
        AuctionOperation aucOperate1;
        
        //Running a auction consumer1 user 
        System.RunAs(auctionConsumer1){
            auctionWithEndStatus = TestDataFactory.createAuctionWithEndedStatus();
                   
            ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithEndStatus);
            aucOperate1 = new AuctionOperation(Psc);
            aucOperate1.save();
        }
        
        //Running as auction consumer2 user 
        System.RunAs(auctionConsumer2){
            System.assert(!aucOperate1.getAuctionStatus());
        }
    }
    
    //Testing End Auction Bid button visibility
    static testMethod void test_getEndAuctionStatus(){
        
        //Setting auction consumer1 user 
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        
        Auction__c auctionWithoutBid;
        Auction__c auctionWithBid;
        
        //Running as auction consumer1 user 
        System.RunAs(auctionConsumer1){
            auctionWithoutBid = TestDataFactory.createAuctionWithoutBid();
                   
            ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithoutBid);
            AuctionOperation aucOperate = new AuctionOperation(Psc);
            aucOperate.save();
            
            //The value needs to be false
            system.assert(!aucOperate.getEndAuctionStatus());
        }
        
        //Setting auction consumer2 user 
        User auctionConsumer2 = TestDataFactory.createBidUserRecords();
        
        //Running as auction consumer2 user 
        System.RunAs(auctionConsumer2){
            auctionWithoutBid.bid_Amount__c = 1000;
            update auctionWithoutBid;
        }
        
        //Setting System Admin user 
        User sysAdmin = TestDataFactory.createCharityAuctionsAdministratorUserRecords();
        
        //Running as System Admin user 
        System.RunAs(sysAdmin){
            ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithoutBid);
            AuctionOperation aucOperate = new AuctionOperation(Psc);
            
            //For Charity Auction Administrator the value needs to be true
            system.assert(aucOperate.getEndAuctionStatus());
        }
    }
    
    //Testing Bid Amount Component visibility
    static testMethod void test_getBidAmountVisibility(){
        
        //Setting auction consumer1 user 
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        
        Auction__c auctionWithoutBid;
        Auction__c auction1;
        Auction__c auction2;
        AuctionOperation aucOperate;
        AuctionOperation aucOperate1;
        
        //Running as auction consumer1 user 
        System.RunAs(auctionConsumer1){
            auctionWithoutBid = TestDataFactory.createAuctionWithoutBid();
                   
            ApexPages.StandardController Psc = new ApexPages.StandardController(auctionWithoutBid);
            aucOperate = new AuctionOperation(Psc);
            aucOperate.save();
            
            System.Assert(!aucOperate.getBidAmountVisibility());
            
            auction1 = TestDataFactory.createAuctionNewWithoutBid();
            
            ApexPages.StandardController Psc1 = new ApexPages.StandardController(auction1);
            aucOperate1 = new AuctionOperation(Psc1);
            aucOperate1.save();                        
        }
        
        //Setting auction consumer2 user 
        User auctionConsumer2 = TestDataFactory.createBidUserRecords();
        
        //Running as auction consumer2 user 
        System.RunAs(auctionConsumer2){
           aucOperate.getBidAmountVisibility();
           
           //The value returned should be true
           System.Assert(aucOperate.getBidAmountVisibility());
           
           aucOperate1.getBidAmountVisibility();
           System.Assert(!aucOperate1.getBidAmountVisibility());
        }
    }
    
    //Testing page redirect/views based on user profile
    static testMethod void test_viewRedirect(){
        
        //Setting auction consumer1 user
        User auctionConsumer1 = TestDataFactory.createUserRecords();
        
        //Running as auction consumer1 user
        System.RunAs(auctionConsumer1){
            Auction__c auctionWithNewStatus = TestDataFactory.createAuctionNewWithoutBid();
            insert auctionWithNewStatus;
        
            ApexPages.StandardController sc = new ApexPages.StandardController(auctionWithNewStatus);
            AuctionOperation aucOperate = new AuctionOperation(sc);
        
            aucOperate.viewRedirect();
        
            Auction__c auctionWithoutBid = TestDataFactory.createAuctionWithoutBid();
            insert auctionWithoutBid;
        
            ApexPages.StandardController sc1 = new ApexPages.StandardController(auctionWithoutBid);
            AuctionOperation aucOperate1 = new AuctionOperation(sc1);
        
            aucOperate1.viewRedirect();
            
            //Setting System Admin user 
            User sysAdmin = TestDataFactory.createSysAdminUserRecords();
            
            //Running as System Admin user
            System.RunAs(sysAdmin){
                aucOperate1.viewRedirect();
            }
            
       //Setting auction consumer2 user 
       User auctionConsumer2 = TestDataFactory.createBidUserRecords();
       
       //Running as auction consumer2 user 
       System.runAs(auctionConsumer2){
           aucOperate1.viewRedirect();
       }
     }
    }
}