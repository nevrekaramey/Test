public with sharing class AuctionHelper{

    //Defining a static boolean variable to keep check for recursive triggers
    private static boolean run = true;
    
    //Method defined to set the static boolean variable to avoid trigger recursion
    public static boolean runOnce(){
        if(run){
            run = false;
            return true;
        }else{
            return run;
        }
    }
    
    //Method to validate auction consumer is not same as the auction owner
    @TestVisible private Boolean auctionConsumerCheck(Map<Id, Auction__c> auctionValues){
        List<Auction__c> auctionList = auctionValues.values();
        Boolean condition = true;
        
        for(Auction__c auction : auctionList){
            if(UserInfo.getUserId() == auction.OwnerId){
                if(auction.Auction_Status__c == 'Ended'){
                    condition = true;
                }else if(auction.Auction_Status__c == 'New' || auction.Bid_Amount__c == null){
                    condition = true;
                }else{
                    condition = false;
                    auctionValues.get(auction.id).addError
                                            ('Auction owner cannot place bid on the auction he is owning or on behalf of other users');
                     }
                    
                }else{
                    condition = true;
                 }
            }
  
            return condition;
    }
    
    //Method call when Auction records are been updated
    public void updateAuctionBidInformation(Map<Id, Auction__c> auctionValues, Map<Id, Auction__c> oldAuctionValues){
        
        List<Auction__c> auctionList = [Select Id, Bid_Amount__c, High_Bidder__c from Auction__c Where Id IN: auctionValues.keySet()];
        List<Bid__c> bidList = [Select Id, OwnerId, Bid_Amount__c from Bid__c Where Auction__c IN: auctionValues.keySet()];
        
        Boolean condition = auctionConsumerCheck(auctionValues);
        
        if(condition){
            updateAuctionRecords(auctionList, auctionValues, oldAuctionValues);
            updateBidRecords(bidList, auctionList, auctionValues, condition, oldAuctionValues); 
        }
    }
    
    //Auction specific update operation
    @TestVisible private void updateAuctionRecords(List<Auction__c> auctionList, Map<Id, Auction__c> auctionValues, Map<Id, Auction__c> oldAuctionValues){
        List<User> updateUserList = new List<User>();
        List<Auction__c> updateAuctionList = new List<Auction__c>();
        List<User> uList = [Select Id, Winning_Bid_Amount__c From User Where Id =: UserInfo.getUserId()];
        User user = new User();
        Set<Id> uId = new Set<Id>();
        
        for(Auction__c a : auctionList){
            if(auctionValues.get(a.id).Bid_Amount__c !=null){
                
                user.id = UserInfo.getUserId();
                user.Winning_Bid_Amount__c = updateWiningBidAmount(auctionList, auctionValues, oldAuctionValues, uList);
                
                a.High_Bidder__c = UserInfo.getUserId();
                    
                    //Insert bid value for new auction bidder
                    if(a.High_Bidder__c != oldAuctionValues.get(a.id).High_Bidder__c){
                        uId.add(oldAuctionValues.get(a.id).High_Bidder__c);
                        
                        //call to deducting the winning bid amount when user has lost the bid
                        updateWinningLostBidAmount(oldAuctionValues, uId);
                    }
                updateAuctionList.add(a);
                updateUserList.add(user);
            }
        }
        
        //checking if the list is not empty to avoid DML on empty list
        if(!updateUserList.isEmpty()){
            update updateUserList;
        }
        
        //checking if the list is not empty to avoid DML on empty list
        if(!updateAuctionList.isEmpty()){
            update updateAuctionList;
        }
    }
    
    //Insert or Update on Bid record associated to specific auction
    @TestVisible private void updateBidRecords(List<Bid__c> bidList, List<Auction__c> auctionList, Map<Id, Auction__c> auctionValues, 
                                    Boolean condition, Map<Id, Auction__c> oldAuctionValues){
        List<Bid__c> updateBidList = new List<Bid__c>();
        
        List<Auction__c> oldAuctionValueList = oldAuctionValues.values();
        
        for(Auction__c a : auctionList){
            Id id = oldAuctionValues.get(a.id).High_Bidder__c;
            
            if((bidList.isEmpty()) ||(a.High_Bidder__c != id)){
                insertAuctionInformation(auctionValues);
            }else{
                for(Bid__c bid : bidList){
                    if(a.id == auctionValues.get(a.id).id){
                        bid.Name = normaliseBidName(auctionValues.get(a.id).Bid_Amount__c, auctionValues.get(a.id).Name);
                        bid.Bid_Amount__c = a.Bid_Amount__c;
                    }
                        updateBidList.add(bid);
                }
        
                if(!updateBidList.isEmpty()){
                    update updateBidList;
                }
            }
        }
    }
    
    //Inserting Bid information when a new auction record is been added or updated
    public void insertAuctionInformation(Map<Id, Auction__c> auctionValues){
        List<Bid__c> bids = new List<Bid__c>();
        
        Bid__c bid = new Bid__c();
        
        List<Auction__c> updateAuctionHighBidder = new List<Auction__c>();
        
        Boolean condition = auctionConsumerCheck(auctionValues);
        
        if(condition){
            for(Integer i=0;i<auctionValues.size();i++){
                for(Id id : auctionValues.keySet()){
                    if(auctionValues.get(id).Bid_Amount__c !=null){
                        bid.Auction__c = auctionValues.get(id).id;
                        bid.Name = normaliseBidName(auctionValues.get(id).Bid_Amount__c, auctionValues.get(id).Name);
                        bid.Bid_Amount__c = auctionValues.get(id).Bid_Amount__c;
                        bids.add(bid);
                    }
                }
            }
        
            if(!bids.isEmpty()){
                System.debug('BID INFORMATION' + bids);
                insert bids;
            }
        }
    }
    
    //Winning Bid Amount Calculation
    @TestVisible private Double updateWiningBidAmount(List<Auction__c> auctionList, Map<Id,Auction__c> auctionValues, 
                                            Map<Id,Auction__c> oldAuctionValues, List<User> uList){
        Double winBidAmount;
        
        for(Auction__c a : auctionList){
            if(auctionValues.get(a.id).Bid_Amount__c !=null){
                
                for(User userBidder : uList){
                    if(userBidder.Winning_Bid_Amount__c == null){
                        winBidAmount = auctionValues.get(a.id).Bid_Amount__c; // neeed to make this more efficient
                    }else{
                        winBidAmount = userBidder.Winning_Bid_Amount__c + auctionValues.get(a.id).Bid_Amount__c;
                    }
                }      
            }
        }
        
        return winBidAmount;
    }
    
    //Deducting the winning bid amount when user has lost the bid
     public void updateWinningLostBidAmount(Map<Id,Auction__c> oldAuctionValues, Set<Id> uId){
       
        List<User> oldUserList = [Select Winning_Bid_Amount__c From User Where Id IN: uId];
        List<Auction__c> auctionList = oldAuctionValues.values();
        List<User> updateUserList = new List<User>();
        
        for(Auction__c a : auctionList){
            for(User u : oldUserList){
                //Check if the winning bid amount on the user is 0 if so keep it to 0 to avoid -ve values
                if(u.Winning_Bid_Amount__c !=0){
                    u.Winning_Bid_Amount__c = u.Winning_Bid_Amount__c - a.Bid_Amount__c;
                    updateUserList.add(u);
                }else{
                    u.Winning_Bid_Amount__c = 0;
                    updateUserList.add(u);
                }
            }
        }
        
        if(!updateUserList.isEmpty()){
            update updateUserList;
        }
    }
    
    //Normalise the bid name
    @TestVisible private String normaliseBidName(Decimal bidAmount, String auctionName){
        return '$' + bidAmount + ' for ' + auctionName;
    }
    
    //Checking for more than 10 concurrent for user
    public static Boolean multipleAuctionCheck(){
        Boolean condition;
        integer count = [Select count() From Auction__c Where High_Bidder__c =: UserInfo.getUserId() AND Auction_Status__c = 'Active'];  
        if(count > 10){
            condition = false;
        }else{
            condition = true;
        }
        
        return condition;
    }
}