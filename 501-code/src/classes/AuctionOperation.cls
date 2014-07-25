public with sharing class AuctionOperation{
    
    private final Auction__c auction;
    
    ApexPages.StandardController controller;
    PageUtility util = new PageUtility();
    
    public AuctionOperation(ApexPages.StandardController con){
        controller = con;
        this.auction = (Auction__c)controller.getRecord();
         
    }
    
    public Boolean getAuctionStatus(){
        return util.checkAuctionStatus(auction.id); 
    }
    
    public Boolean getEndAuctionStatus(){
        return util.checkEndAuctionStatus(auction.id);
    }
    
    public Boolean getBidAmountVisibility(){
        return util.checkAuctionBidFieldVisibilty(auction.id);
    }
    
    public PageReference viewRedirect(){
        List<Auction__c> auctionList = [Select OwnerId, Auction_Status__c From Auction__c where Id =: auction.id];
        try{
            PageReference redirect;
            
            
            for(Auction__c a : auctionList){
                if(a.Auction_Status__c == 'New' && userProfileCheck()){
                
                    redirect = new PageReference('/apex/AuctionCreatePage');
                    redirect.getParameters().put('id', a.id);
                    redirect.setRedirect(true);
                    
                }else if(a.Auction_Status__c == 'Active' && userProfileCheck()){
                
                    redirect = new PageReference('/apex/AuctionEndPage');
                    redirect.getParameters().put('id', a.id);
                    redirect.setRedirect(true);
                    
                }else if(systemAdminProfileCheck()){
                
                    redirect = new PageReference('/apex/AuctionPage');
                    redirect.getParameters().put('id', a.id);
                    redirect.setRedirect(true);
                }else{
                    redirect = new PageReference('/apex/AuctionBidPage');
                    redirect.getParameters().put('id', a.id);
                    redirect.setRedirect(true);
                }
            }
            
            return redirect;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'unknown error occurred'));
            return null;
        }
    }
    
    @TestVisible private Boolean userProfileCheck(){
        Boolean condition;
        
        List<Profile> profileList = [Select Name From Profile where Id =: UserInfo.getProfileId()];
        List<Auction__c> auctionList = [Select OwnerId, Registered_Charity__c From Auction__c where Id =: auction.id]; 
         List<Account> charityAccountList = new List<Account>();
         List<ID> accId = new List<ID>();
         
         for(Auction__c a: auctionList){
            accId.add(a.Registered_Charity__c);
        }
        
        charityAccountList = [Select OwnerId From Account Where Id IN: accId];
        
        for(Auction__c a : auctionList){
            for(Account acc: charityAccountList){
                for(Profile p : profileList){
                    if((p.Name == 'Charity Auctions Administrator') 
                        || (p.Name == 'Charity Auctions Consumer' && a.ownerId == UserInfo.getUserId())
                        || (p.Name == 'Charity Auctions Charity' && acc.ownerId == UserInfo.getUserId())){
                        condition = true;
                    }else{
                        condition = false;
                    }
                }
            }
        }
        
        return condition;
    }
    
    @TestVisible private Boolean systemAdminProfileCheck(){
        Boolean condition;
        
        List<Profile> profileList = [Select Name From Profile where Id =: UserInfo.getProfileId()];
        List<Auction__c> auctionList = [Select OwnerId From Auction__c where Id =: auction.id]; 
        
        for(Auction__c a : auctionList){
            for(Profile p : profileList){
                if(p.Name == 'System Administrator'){
                        condition = true;
                }else{
                    condition = false;
                }
            }
        }
        
        return condition;
    }
    
    public PageReference save(){
    
        try{
            if(auction.Bid_Amount__c !=null){
                 auction.High_Bidder__c = UserInfo.getUserId();
            }
            
            PageReference pageRef = new PageReference('/a06/o');
            pageRef.setRedirect(true);
            
           upsert auction;
           return pageRef;
            
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error creating new auction.'));
            return null;
        }
    }
    
    public PageReference placeOrUpdateBid(){
    
        try{
            if(auction.Bid_Amount__c !=null){
                 auction.High_Bidder__c = UserInfo.getUserId();
            }
            
            update auction;
            
            PageReference pageRef = new PageReference('/a06/o');
            pageRef.setRedirect(true);
            return pageRef;
            
        }catch(Exception e){
            System.debug('ERROR:' + e.getMessage());
            if(e.getMessage().contains('DUPLICATE_VALUE, duplicate value found:')){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL,'Cannot update an already placed bid by same user. Please bid on new auction'));
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error placing bid on the auction'));
            }
            
            return null;
        }
    }
    
    public PageReference startAuction(){
    
        try{
            if(auction.Bid_Amount__c !=null){
                 auction.High_Bidder__c = UserInfo.getUserId();
            }
            auction.Auction_Status__c = 'Active';
            upsert auction;
            
            PageReference auctionPage = new PageReference('/apex/AuctionEndPage');
            auctionPage.getParameters().put('id', auction.id);
            auctionPage.setRedirect(true);
            return auctionPage;
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error creating and starting new auction.'));
            return null;
        }
    }
    
    public PageReference endAuction(){
        try{
            if(auction.Reserve_Amount__c == null){
                auction.Auction_Status__c = 'Ended';    
                update auction; 
            }else if(auction.Reserve_Amount__c <= auction.Bid_Amount__c){
                auction.Auction_Status__c = 'Ended';    
                update auction; 
            }
             return null;
            
        }catch(DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Ending the auction.'));
            return null;
        }
    }
    
    public PageReference cancelAuction(){
            PageReference pageRef = new PageReference('/a06/o');
            pageRef.setRedirect(true);
            return pageRef;
    }
}