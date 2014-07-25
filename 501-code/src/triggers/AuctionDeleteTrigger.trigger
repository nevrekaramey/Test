trigger AuctionDeleteTrigger on Auction__c (before delete) {
            
            Map<Id, Auction__c> auctionValues = new Map<Id, Auction__c>();
            Set<Id> uId = new Set<Id>();
            
            for(Auction__c auction : Trigger.old){
               auctionValues.put(auction.id, auction);
               uId.add(auction.High_Bidder__c);
            }
            
            List<Bid__c> bidList = [Select Id From Bid__c Where Auction__c IN: auctionValues.keySet()];
            
            if(!bidList.isEmpty()){
                delete bidList;
            }
}