trigger AuctionUpdate on Auction__c (after update, after insert) {

    AuctionHelper aucHelper = new AuctionHelper();
    
    if(Trigger.isUpdate){
    
        if(AuctionHelper.runOnce()){
            
            Map<Id, Auction__c> auctionValues = new Map<Id, Auction__c>();
            Map<Id, Auction__c> oldAuctionValues = new Map<Id, Auction__c>();
        
            for(Auction__c auction : Trigger.new){
               auctionValues.put(auction.id, auction);
            }
            
            for(Auction__c oldAuction : Trigger.old){
                oldAuctionValues.put(oldAuction.id, oldAuction);
            }
            
            if(AuctionHelper.multipleAuctionCheck()){
                aucHelper.updateAuctionBidInformation(auctionValues, oldAuctionValues);
            }else{    
                List<Auction__c> auctionList = auctionValues.values();
                for(Auction__c auction : auctionList){
                    auctionValues.get(auction.id).addError('Bidding on more the 10 auction not allowed');
                }
            } 
        }
    }
    
    if(Trigger.isInsert){
        
        Map<Id, Auction__c> auctionValues = new Map<Id, Auction__c>();
        
        for(Auction__c auction : Trigger.new){
            auctionValues.put(auction.id, auction);
        }
        
        if(AuctionHelper.multipleAuctionCheck()){
            aucHelper.insertAuctionInformation(auctionValues);
        }
        
    }
}