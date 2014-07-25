public with sharing class BidHelper{
    
    private static boolean run = true;
    
    public static boolean runOnce(){
        if(run){
             run=false;
             return true;
        }else{
            return run;
        }
    }
    
    //Check the bid amount with reserve bid amount if set
    public void checkBidAmountWithReserveAmount(Map<Id, Bid__c> bidRecordId){
        List<Auction__c> auctionList = [Select Id, Name, Auction_Status__c, Bid_Amount__c, Reserve_Amount__c From Auction__c Where Id IN: bidRecordId.keySet()];
    
        for(Auction__c auctions : auctionList){
           
                if(auctions.Auction_Status__c == 'Active' || auctions.Auction_Status__c == 'Ended' ){
                    if(auctions.Reserve_Amount__c !=null){
                        if(auctions.Reserve_Amount__c <= auctions.Bid_Amount__c){}
                        else{
                           bidRecordId.get(auctions.id).addError('Bid Amount needs to be equal or greater than Auction Reserve Amount');   
                        }   
                    }
                }else{    
                   bidRecordId.get(auctions.id).addError('Auction is inactive');
                }
        }
    }
    
    
    //Method to check if current bid amount is > that old bid amount
    public void checkOldBidAmount(Map<Id,Bid__c> oldBidRecordId, Map<Id,Bid__c> newBidRecordId){
        List<Bid__c> oldBidValues = oldBidRecordId.values();
        List<Bid__c> newBidValues = newBidRecordId.Values();
        
        Set<Id> auctionId = new Set<Id>();
        
        for(Bid__c bids : newBidValues){
           auctionId.add(bids.auction__c);
        }
        
        AggregateResult[] highBidValues = [Select Max(Bid_Amount__c) From Bid__c Where Auction__c IN: auctionId];
     
        
        for(AggregateResult highBid : highBidValues){
            for(Bid__c oldBid : oldBidValues){
                for(Bid__c bid : newBidValues){
                    Double value = double.valueof(highBid.get('expr0'));
                    if( value > bid.Bid_Amount__c){
                        newBidRecordId.get(bid.id).addError('Bid Amount needs to be greater than old bid amount');
                    } else if(oldBid.Bid_Amount__c > bid.Bid_Amount__c){
                        newBidRecordId.get(bid.id).addError('Bid Amount needs to be greater than old bid amount');
                    }
                    else{
                        checkBidAmountWithReserveAmount(newBidRecordId);
                    }
                }
            }
        }
   }
}