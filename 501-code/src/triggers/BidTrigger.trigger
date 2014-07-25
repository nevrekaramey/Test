trigger BidTrigger on Bid__c (before insert, before update) {

    AuctionHelper aucHelper = new AuctionHelper();
    BidHelper bidhelp = new BidHelper();
    Map<Id,Bid__c> bidRecordId = new Map<Id,Bid__c>();
    
    if(Trigger.isInsert){
        if(BidHelper.runOnce()){
    
        for(Bid__c bids : Trigger.New){
            bidRecordId.put(bids.Auction__c, bids);
        }
        
        bidHelp.checkBidAmountWithReserveAmount(bidRecordId);
        }
    }
    
    if(Trigger.isUpdate){
        Map<Id,Bid__c> oldBidRecordId = new Map<Id,Bid__c>();
        Map<Id,Bid__c> newBidRecordId = new Map<Id,Bid__c>();
        
        for(Bid__c bids : Trigger.Old){
            oldBidRecordId.put(bids.id,bids);
        }
        
        for(Bid__c bids : Trigger.New){
            newBidRecordId.put(bids.id,bids);
        }
        
        bidHelp.checkOldBidAmount(oldBidRecordId, newBidRecordId);
    }
}