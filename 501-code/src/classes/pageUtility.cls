public class pageUtility{
    
    //Check Place Auction Bid button visibilty
    public Boolean checkAuctionStatus(Id auctionID){
        List<Auction__c> auctionList = [Select OwnerId, Auction_Status__c, Bid_Amount__c,Registered_Charity__c From Auction__c Where Id =: auctionID];
        List<Profile> profileList = [Select Name From Profile where Id =: UserInfo.getProfileId()];
        
        List<Account> charityAccountList = new List<Account>();
        List<ID> accId = new List<ID>();
        
        Boolean status;
        
        for(Auction__c a: auctionList){
            accId.add(a.Registered_Charity__c);
        }
        
        charityAccountList = [Select OwnerId From Account Where Id IN: accId];
        
        for(Auction__c a : auctionList){
            for(Account acc: charityAccountList){    
                for(Profile p : profileList){
                    if((a.Auction_Status__c == 'Active' && a.Bid_Amount__c !=null)
                        ||(a.Auction_Status__c == 'Active' && a.Bid_Amount__c ==null) && (a.OwnerId != UserInfo.getUserId())){
                        status = true;
                    }else if((a.Auction_Status__c == 'Ended') || (a.Bid_Amount__c ==null)){
                        status = false;
                    }else if(a.Auction_Status__c == 'New' && auctionId == null){
                        status = true;
                    }
                }
            }
        }
        
        return status;
    }
    
    //Check Place Auction Bid Field visibilty
    public Boolean checkAuctionBidFieldVisibilty(Id auctionID){
        List<Auction__c> auctionList = [Select OwnerId, Auction_Status__c, Bid_Amount__c From Auction__c Where Id =: auctionID];
        List<Profile> profileList = [Select Name From Profile where Id =: UserInfo.getProfileId()];
        
        Boolean status;
        
        for(Auction__c a : auctionList){
            for(Profile p : profileList){
                if(a.OwnerId != UserInfo.getUserId()){
                    if(a.Auction_Status__c != 'Ended' && a.Auction_Status__c != 'New' ){
                        status = true;
                    } else if(a.Auction_Status__c == 'Ended' || a.Auction_Status__c == 'New'){
                        status = false;
                    }else{
                        status = false;
                    }
                    
                }else {
                    status = false;
                }
            }
        }
        return status;
    }
    
    //Check End Auction button visibilty
    public Boolean checkEndAuctionStatus(Id auctionID){
        List<Auction__c> auctionList = 
            [Select OwnerId, Auction_Status__c, Bid_Amount__c, Registered_Charity__c From Auction__c Where Id =: auctionID];
        List<Profile> profileList = [Select Name From Profile where Id =: UserInfo.getProfileId()];
        List<Account> charityAccountList = new List<Account>();
        List<ID> accId = new List<ID>();
        
        Boolean status;
        
        for(Auction__c a: auctionList){
            accId.add(a.Registered_Charity__c);
        }
        
        charityAccountList = [Select OwnerId From Account Where Id IN: accId];
       
        for(Auction__c a : auctionList){
                for(Account acc: charityAccountList){
                    for(Profile p : profileList){
                        if((a.Auction_Status__c == 'Active' && a.Bid_Amount__c !=null) 
                            && (a.OwnerId == UserInfo.getUserId() && p.Name == 'Charity Auctions Consumer') 
                            || (a.Auction_Status__c == 'Active' && a.Bid_Amount__c !=null) 
                                && (p.Name == 'Charity Auctions Administrator')
                            || (a.Auction_Status__c == 'Active' && a.Bid_Amount__c !=null) 
                            && (acc.OwnerId == UserInfo.getUserId())){
                                status = true;
                        }else if((a.Auction_Status__c == 'Ended') || (a.Bid_Amount__c ==null)){
                            status = false;
                        }else if(a.Auction_Status__c == 'New' && auctionId == null){
                            status = true;
                        }
                    }
                }
        }
        
        return status;
    }
}