public class trgQuoteHandler
{
    public static void trgQuote(List<Quote> lstNewQuote, Map<Id, Quote> mapNewQuote, Map<Id, Quote> mapOldQuote, System.TriggerOperation trgEvent)
    {
        switch on trgEvent {
            when BEFORE_INSERT {
                before_InsertUpdate(lstNewQuote, mapOldQuote, false);                
                
            }
            when BEFORE_UPDATE {
                before_InsertUpdate(lstNewQuote, mapOldQuote, true);
                // Added by Neha : CR-007447
                TriggerEnabled__c wifiCS = TriggerEnabled__c.getValues('validateWifiQuote');
                if(wifiCS !=null && wifiCs.Active__c == true)
                {
                    validatePartnerRepInfo(lstNewQuote , mapNewQuote, mapOldQuote);
                }
                
                
                
                
            }
            when AFTER_INSERT {  
                after_InsertUpdate(lstNewQuote, mapOldQuote, true);
            }
            when AFTER_UPDATE {
                after_InsertUpdate(lstNewQuote, mapOldQuote, false);
            }
        }
    }
    
    // add By Nitish Bhardwaj
    ///<SUMMARY>
    ///DESC: 
    ///EVENT: before insert, before update
    public static void updateTermsOfQuote(list<quote> lstQuote , Boolean isUpdate)
    {
        
        if(lstQuote!=null && lstQuote.size()>0)
        {
            system.debug('test====>>>'+lstQuote);
            map<id,string> map_Accid_Termofquote = new map<id,string>();   //map_AccId_termOfQuote
            list<Terms_of_Quote__mdt> lstTermofquote = [select id,MasterLabel,Label,Account_Name__c,terms_and_condition__c from Terms_of_Quote__mdt];
            list<quote> lstUpdateQuote = new list<quote>();
            set<id> setQuoteId = new set<id>();
            system.debug('test====>>>'+lstTermofquote);
            if(lstTermofquote != null && lstTermofquote.size()>0){
                for(Terms_of_Quote__mdt eachMtd : lstTermofquote)
                {
                    If(eachMtd.MasterLabel.length()>=15)
                    map_Accid_Termofquote.put(eachMtd.MasterLabel,eachMtd.terms_and_condition__c);
                    
                }
                
            } 
            if(lstQuote != null && lstQuote.size()>0)
            {
                 for(quote eachQuote : lstQuote)
                {
                    setQuoteId.add(eachQuote.id);
                }
            }
            
            if(lstQuote != null && lstQuote.size()>0)
            {
                list<quoteLineItem> lstQtli = new list<QuoteLineItem>();
                if(setQuoteId != null && setQuoteId.size()>0 && isUpdate)
                {
             lstQtli = [select id,AccountId,Update_Terms_of_quote__c,(select id,Product_Name__c from quoteLineItems Where Product_Name__c like '%OSV%' OR Product_Name__c like '%SVC%') from quote where id =: setQuoteId limit 1].quoteLineItems;
                }
                
                system.debug('lstQtli ====>>'+lstQtli);
                for(quote eachQuote : lstQuote)
                {
                    
                    if(trgQuoteLineItemHandler.runcheck && map_Accid_Termofquote != null && !map_Accid_Termofquote.isempty() && map_Accid_Termofquote.size()>0 && eachQuote.AccountId != null && map_Accid_Termofquote.containskey(string.valueOf(eachQuote.AccountId).substring(0, 15)))
                    {
                        If(lstQtli  != null && lstQtli.size()>0 && isUpdate)
                        {
                             eachQuote.Update_Terms_of_quote__c = map_Accid_Termofquote.get(string.valueOf(eachQuote.AccountId).substring(0, 15))+'<br/>' + system.label.Quotation ;                       
                        }
                        else
                        { system.debug('Fail====>>>');
                             eachQuote.Update_Terms_of_quote__c = map_Accid_Termofquote.get(string.valueOf(eachQuote.AccountId).substring(0, 15)) ;                       
                        }
                       
                    }
                    else
                    {
                         If(lstQtli  != null && lstQtli.size()>0 && isUpdate && trgQuoteLineItemHandler.runcheck && system.label.Terms_of_quote_in_general != null && system.label.Terms_of_quote_in_general != null)
                        {
                            eachQuote.Update_Terms_of_quote__c = system.label.Terms_of_quote_in_general+'<br/>' + system.label.Quotation + '<br/>' +system.label.Payment_terms_last;
                        }
                        else
                        {
                           if(trgQuoteLineItemHandler.runcheck && system.label.Terms_of_quote_in_general != null && system.label.Terms_of_quote_in_general != null)
                        {
                            eachQuote.Update_Terms_of_quote__c = system.label.Terms_of_quote_in_general + '<br/>' + system.label.Payment_terms_last; 
                        } 
                        }
                        
                        
                    }
                    lstUpdateQuote.add(eachQuote); // lstUpdateQuote
                }
                system.debug('lstUpdateQuote------->>>'+lstUpdateQuote);
            }
            
            
            
        }
        
        
    }
    
    // End    
    
    ///<SUMMARY>
    ///DESC: 
    ///EVENT: before insert, before update
    ///</SUMMARY>
    static void before_InsertUpdate(List<Quote> lstNewQuote, Map<Id, Quote> mapOldQuote, Boolean isUpdate)
    {
        
        // Start Tax Calculation Code
        
        TriggerEnabled__c TaxCaculate = TriggerEnabled__c.getInstance('TaxCalci');
        if (TaxCaculate == null || TaxCaculate.Active__c == true) 
        {
            decimal totalamount = 0;
            decimal taxamount = 0;
            for(Quote eachQuote:lstNewQuote)
            {
                if(eachQuote != null && eachQuote.TotalPrice != null && eachQuote.TotalPrice == 0)
                {
                    if(eachQuote.Tax__c != null && (eachQuote.Tax__c > 100 || eachQuote.Tax__c < 0))
                    {
                        eachQuote.Tax__c.adderror('Please enter the value between 0% to 100%');
                    }
                    else if(eachQuote.TotalPrice == 0 && eachQuote.Tax__c != null)
                    {
                        eachQuote.Tax = 0;
                    }
                    else if(eachQuote.Tax__c == 0)
                    {
                        eachQuote.Tax = 0;
                    }
                    else if(mapOldQuote != null && mapOldQuote.size()>0)
                    {
                        if(eachQuote.Tax__c == null && mapOldQuote.get(eachQuote.Id).Tax__c != eachQuote.Tax__c )
                        {
                            eachQuote.Tax = null;
                        }
                        else if(eachQuote.TotalPrice == 0 && mapOldQuote.get(eachQuote.Id).TotalPrice != eachQuote.TotalPrice )
                        {
                            eachQuote.Tax = 0;
                        }
                    } 
                    
                }             
                else if(eachQuote != null && eachQuote.TotalPrice != null && eachQuote.TotalPrice > 0)
                {
                    totalamount = eachQuote.TotalPrice;
                    
                    if(eachQuote.Tax__c != null && (eachQuote.Tax__c > 100 || eachQuote.Tax__c < 0))
                    {
                        eachQuote.Tax__c.adderror('Please enter the value between 0% to 100%');
                    }
                    else if(eachQuote.Tax__c != null && eachQuote.Tax__c >0)
                    {
                        taxamount = eachQuote.Tax__c * totalamount/100;
                        eachQuote.Tax = taxamount.setscale(2);
                    }
                    else if(eachQuote.Tax__c == 0)
                    {
                        eachQuote.Tax = 0;
                    }
                    else if(mapOldQuote != null && mapOldQuote.size()>0)
                    { 
                        if(eachQuote.Tax__c == null && eachQuote.Tax__c != mapOldQuote.get(eachQuote.Id).Tax__c)
                        {
                            eachQuote.Tax = null;
                        }
                    }   
                }
            }
        }
        
        
        // Stop Tax Calculation Code
        
        
        
        TriggerEnabled__c myCS = TriggerEnabled__c.getValues('QuoteTrigger');
        System.debug('myCS------------------>'+myCS);
        System.debug('clsRecusrsiveCheck.byPassQuoteTrg----------------->'+clsRecusrsiveCheck.byPassQuoteTrg);
        
        if((myCS==Null || (myCS.Object_Name__c=='Quote' && myCS.Active__c==True)) && ! clsRecusrsiveCheck.byPassQuoteTrg && clsRecusrsiveCheck.byPassQuoteSyncTrigger)
        {
            Set<Id> setOppID = New Set<ID>();
            // hold Quote Id to calculate tariff fee.
            Set<Id> setQuoteId = new Set<Id>();
            Map<Id, Decimal> mapTariffFee = new Map<Id, Decimal>();
            
            for(Quote objQuote : lstNewQuote)
            {
                setOppID.add(objQuote.OpportunityId);
                // Akshay: re-calculat tariff fee when quote is edited. 
                if(isUpdate)
                {
                    if(!objQuote.Remove_Tariff__c && mapOldQuote.get(objQuote.Id).Remove_Tariff__c == true)
                        setQuoteId.add(objQuote.id);
                    if(objQuote.Quote_Line_Item_Count__c == 0)
                        mapTariffFee.put(objQuote.Id, 0.00);
                }
            }
            
            System.debug('setOppID--------------->'+setOppID);
            System.debug('mapTariffFee--------------------->'+mapTariffFee);
            // Calculate tariff fee in respect of quote line item.
            if(setQuoteId != null && setQuoteId.size() > 0)
            {
                String skuName = System.label.TariffFeeNotAppliedPP;
                Set<String> setSKUName = new Set<String>();
                
                if(String.isNotBlank(skuName))
                {
                    List<String> lstSKUName = skuName.split(',');
                    setSKUName = new Set<String>(lstSKUName);
                }
                
                List<QuoteLineItem> lst_QuoteLineItemRec = [Select Product_Name__c,QuoteId,TotalPrice,Quote.Opportunity.Account.Tariff_Fee__c from QuoteLineItem where QuoteId IN :  setQuoteId AND (NOT Product_Name__c like '%7130%')];
                System.debug('lst_QuoteLineItemRec--------------->'+lst_QuoteLineItemRec);
                
                if(lst_QuoteLineItemRec != null && lst_QuoteLineItemRec.size() > 0)
                {
                    for(QuoteLineItem eachQLI : lst_QuoteLineItemRec)
                    {
                        if(setSKUName != null && setSKUName.size() > 0 && ! setSKUName.contains(eachQLI.Product_Name__c.subStringBefore('-')) && ! setSKUName.contains(eachQLI.Product_Name__c))
                        {
                            Decimal tariffFee = eachQLI.Quote.Opportunity.Account.Tariff_Fee__c != null ? eachQLI.Quote.Opportunity.Account.Tariff_Fee__c/100 : 0.055;
                            System.debug('Total Price------>'+eachQLI.TotalPrice);
                            if(! mapTariffFee.containsKey(eachQLI.QuoteId))
                                mapTariffFee.put(eachQLI.QuoteId, eachQLI.TotalPrice * tariffFee);
                            else
                                mapTariffFee.put(eachQLI.QuoteId, mapTariffFee.get(eachQLI.QuoteId) + eachQLI.TotalPrice * tariffFee);
                        }
                    }
                }
            } 
            
            System.debug('mapTariffFee-------------------->'+mapTariffFee);
            system.debug('setOppID------------->>>>>>>>>' + setOppID);
            Map<id, Opportunity> mapOpportunity = new Map<id, Opportunity>();
            Map<id, opportunity> mapOpportunityD = new Map<id, Opportunity>();
            Map<id, Opportunity> mapOpportunityn = new Map<id, Opportunity>();
            Map<id, Opportunity> mapAllOpportunity = new Map<id, Opportunity>();
            //for(Opportunity objOpportunity: [Select Assign_Reseller__c, Assign_Reseller__r.BillingLatitude, Assign_Reseller__r.BillingLongitude, Assign_Reseller__r.BillingCity,Assign_Reseller__r.BillingCountry, Assign_Reseller__r.BillingPostalCode, Assign_Reseller__r.BillingState, Assign_Reseller__r.BillingStreet, id, AccountId , Account.BillingLatitude, Account.BillingLongitude, Account.BillingCity,Account.BillingCountry, Account.BillingCountryCode, Account.BillingPostalCode, Account.BillingState, Account.BillingStateCode, Account.BillingStreet from Opportunity where id in :setOppID]){
            
            for(Opportunity objOpportunity: [Select Notes__c,Is_Default_Product__c, Assign_Reseller__c,Assign_reseller__r.name, Assign_Reseller__r.BillingLatitude, 
                                             Assign_Reseller__r.BillingLongitude, Assign_Reseller__r.BillingCity,Assign_Reseller__r.BillingCountry,Assign_Reseller__r.BillingCountryCode, 
                                             Assign_Reseller__r.BillingPostalCode,Assign_Reseller__r.BillingStateCode, Assign_Reseller__r.BillingState, Assign_Reseller__r.BillingStreet,
                                             Assign_Distributor__c,Assign_Distributor__r.name, Assign_Distributor__r.BillingLatitude, Assign_Distributor__r.BillingLongitude, Assign_Distributor__r.BillingCity,
                                             Assign_Distributor__r.BillingCountry,Assign_Distributor__r.BillingCountryCode,Assign_Distributor__r.BillingStateCode, Assign_Distributor__r.BillingPostalCode, 
                                             Assign_Distributor__r.BillingState, Assign_Distributor__r.BillingStreet, id,Account.name, AccountId , Account.BillingLatitude, Account.BillingLongitude, 
                                             Account.BillingCity,Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet, Account.BillingCountryCode, 
                                             Account.BillingStateCode from Opportunity where id in :setOppID]
               )
            {
                //Assign_Reseller__r
                if(objOpportunity.Assign_Reseller__c!=null && objOpportunity.Assign_distributor__c==null)
                    mapOpportunity.put(objOpportunity.id, objOpportunity);
                else if(objOpportunity.Assign_distributor__c!=null && objOpportunity.Assign_Reseller__c==null)
                    mapOpportunityD.put(objOpportunity.id, ObjOpportunity);
                else if(objOpportunity.Assign_distributor__c!=null && objOpportunity.Assign_Reseller__c!=null)
                    mapOpportunityD.put(ObjOpportunity.id, ObjOpportunity);
                else if(objOpportunity.Assign_distributor__c==null && objOpportunity.Assign_Reseller__c==null)
                    mapOpportunityn.put(ObjOpportunity.id, ObjOpportunity);
                
                mapAllOpportunity.put(objOpportunity.id, objOpportunity);     
            }
            system.debug('mapOpportunity-------->>>>>>>>>>>>' + mapOpportunity);
            
            for(Quote objQuote : lstNewQuote)
            {
                // populate tariff fee on Quote.
                if(objQuote.Remove_Tariff__c)
                    objQuote.Tariff_Fee__c = null;
                else if(mapTariffFee != null && mapTariffFee.size() > 0 && mapTariffFee.containsKey(objQuote.id))
                {
                    objQuote.Tariff_Fee__c = mapTariffFee.get(objQuote.id);
                    objQuote.Tariff_Fee_Background__c = mapTariffFee.get(objQuote.id);
                }
                
                system.debug('I am here ' + objQuote.OpportunityId);
                if(!isupdate)
                {
                    if(mapOpportunity.containsKey(objQuote.OpportunityId))
                    {
                        system.debug('I am here1');
                        system.debug('mapOpportunity.get(objQuote.OpportunityId).Account.BillingCity--->>' + mapOpportunity.get(objQuote.OpportunityId).Account.BillingCity);
                        objQuote.BillingName = mapOpportunity.get(objQuote.OpportunityID).Assign_Reseller__r.name;
                        objQuote.BillingStreet = mapOpportunity.get(objQuote.OpportunityId).Assign_Reseller__r.BillingStreet;
                        objQuote.BillingCity = mapOpportunity.get(objQuote.OpportunityId).Assign_Reseller__r.BillingCity;
                        objQuote.BillingCountry = mapOpportunity.get(objQuote.OpportunityId ).Assign_Reseller__r.BillingCountry;
                        objQuote.BillingCountryCode = mapOpportunity.get(objQuote.OpportunityId ).Assign_Reseller__r.BillingCountryCode;
                        objQuote.BillingLatitude = mapOpportunity.get(objQuote.OpportunityId ).Assign_Reseller__r.BillingLatitude;
                        objQuote.BillingLongitude = mapOpportunity.get(objQuote.OpportunityId ).Assign_Reseller__r.BillingLongitude;
                        objQuote.BillingPostalCode = mapOpportunity.get(objQuote.OpportunityId ).Assign_Reseller__r.BillingPostalCode;
                        objQuote.BillingState = mapOpportunity.get(objQuote.OpportunityId ).Assign_Reseller__r.BillingState;
                        objQuote.BillingStateCode = mapOpportunity.get(objQuote.OpportunityId ).Assign_Reseller__r.BillingStateCode;         
                    }
                    else if(mapOpportunityD.containsKey(objQuote.OpportunityId))
                    {
                        system.debug('Opportunity Distributor Present');
                        system.debug('mapOpportunityD.get(objQuote.OpportunityId).Account.BillingCity--->>' + mapOpportunityD.get(objQuote.OpportunityId).Account.BillingCity);
                        objQuote.BillingName = mapOpportunityD.get(objQuote.OpportunityID).Assign_distributor__r.name;
                        objQuote.BillingStreet = mapOpportunityD.get(objQuote.OpportunityId).Assign_distributor__r.BillingStreet;
                        objQuote.BillingCity = mapOpportunityD.get(objQuote.OpportunityId).Assign_distributor__r.BillingCity;
                        objQuote.BillingCountry = mapOpportunityD.get(objQuote.OpportunityId ).Assign_distributor__r.BillingCountry;
                        objQuote.BillingCountryCode = mapOpportunityD.get(objQuote.OpportunityId ).Assign_distributor__r.BillingCountryCode;
                        objQuote.BillingLatitude = mapOpportunityD.get(objQuote.OpportunityId ).Assign_distributor__r.BillingLatitude;
                        objQuote.BillingLongitude = mapOpportunityD.get(objQuote.OpportunityId ).Assign_distributor__r.BillingLongitude;
                        objQuote.BillingPostalCode = mapOpportunityD.get(objQuote.OpportunityId ).Assign_distributor__r.BillingPostalCode;
                        objQuote.BillingState = mapOpportunityD.get(objQuote.OpportunityId ).Assign_distributor__r.BillingState;
                        objQuote.BillingStateCode = mapOpportunityD.get(objQuote.OpportunityId ).Assign_distributor__r.BillingStateCode;         
                    }
                    else if(mapOpportunityn.containsKey(objQuote.OpportunityId))
                    {
                        objQuote.BillingName = mapOpportunityn.get(objQuote.OpportunityId).Account.name;
                        objQuote.BillingStreet= mapOpportunityn.get(objQuote.OpportunityId).Account.BillingStreet;
                        objQuote.BillingCity= mapOpportunityn.get(objQuote.OpportunityID).Account.BillingCity;
                        ObjQuote.BillingCountry= mapOpportunityn.get(objQuote.OpportunityId).Account.BillingCountry;
                        ObjQuote.BillingCountryCode= mapOpportunityn.get(objQuote.OpportunityId).Account.BillingCountryCode;
                        ObjQuote.BillingLatitude= mapOpportunityn.get(objQuote.OpportunityId).Account.BillingLatitude;
                        ObjQuote.BillingLongitude = mapOpportunityn.get(objQuote.OpportunityId).Account.BillingLongitude;
                        ObjQuote.BillingPostalCode = mapOpportunityn.get(ObjQuote.OpportunityID).Account.BillingPostalCode;
                        ObjQuote.BillingState = mapOpportunityn.get(ObjQuote.OpportunityId).Account.BillingState;
                        ObjQuote.BillingStateCode = mapOpportunityn.get(ObjQuote.OpportunityId).Account.BillingStateCode;
                    }
                }
                string strNotes;
                if(mapAllOpportunity.get(objQuote.OpportunityId).Notes__c!=Null){   
                    if(objQuote.Notes__c!=null)
                    { 
                        if(!objQuote.Notes__c.equalsIgnoreCase(mapAllOpportunity.get(objQuote.OpportunityId).Notes__c))                 
                        {   
                            strNotes = ObjQuote.Notes__c.SubStringafter('Quote Notes:');
                            if(strNotes != null)
                                objQuote.Notes__c = 'Opportunity Notes: ' + mapAllOpportunity.get(objQuote.OpportunityId).Notes__c +'\n'+ ' Quote Notes:'+strNotes ;
                            else
                                objQuote.Notes__c = 'Opportunity Notes: ' + mapAllOpportunity.get(objQuote.OpportunityId).Notes__c +'\n'+ ' Quote Notes:'+objQuote.Notes__c ; 
                        }
                    }
                    
                    else
                        objQuote.Notes__c = 'Opportunity Notes: ' + mapAllOpportunity.get(objQuote.OpportunityId).Notes__c +'\n'+' Quote Notes: ';
                }
                else if(ObjQuote.Notes__c !=null && objQuote.Notes__c.containsIgnoreCase('Quote Notes'))
                {
                    ObjQuote.Notes__c = 'Quote Notes: ' +ObjQuote.Notes__c.SubStringafter('Quote Notes:');                                          
                }
                else if(ObjQuote.Notes__c !=null && !objQuote.Notes__c.containsIgnoreCase('Quote Notes'))
                {
                    objQuote.Notes__c = 'Quote Notes: ' +objQuote.Notes__c;
                }
                
                //Akshay: to check if default products are added to opportunity then make "Is default Product" checkbox to true.
                if(mapAllOpportunity != null && mapAllOpportunity.size() > 0 && mapAllOpportunity.containsKey(objQuote.OpportunityId))
                    objQuote.Is_Default_Product__c = mapAllOpportunity.get(objQuote.OpportunityId).Is_Default_Product__c;
            }
        }
    }
    
    ///<SUMMARY>
    ///DESC: 
    ///EVENT: after insert, after update
    ///</SUMMARY>
    static void after_InsertUpdate(List<Quote> lstNewQuote, Map<Id, Quote> mapOldQuote, Boolean isInsert)
    {
        TriggerEnabled__c myCS = TriggerEnabled__c.getValues('QuoteSyncTrigger');
        System.debug('myCS------------------>'+myCS);
        if(myCS == null || (myCS.Object_Name__c=='Quote' && myCS.Active__c==True))
        {
            if (TriggerStopper.stopQuote)
                return;
            TriggerStopper.stopQuote = true;  
            
            Set<String> quoteFields = QuoteSyncUtil.getQuoteFields();
            List<String> oppFields = QuoteSyncUtil.getOppFields();
            String quote_fields = QuoteSyncUtil.getQuoteFieldsString();
            String opp_fields = QuoteSyncUtil.getOppFieldsString();
            Map<Id, Id> startSyncQuoteMap = new Map<Id, Id>();
            String quoteIds = '';
            
            for (Quote quote : lstNewQuote)
            {
                if (quote.isSyncing && !mapOldQuote.get(quote.Id).isSyncing)
                    startSyncQuoteMap.put(quote.Id, quote.OpportunityId);
                
                if (quoteIds != '')
                    quoteIds += ', ';
                quoteIds += '\'' + quote.Id + '\'';
            }
            
            String quoteQuery = 'select Id, OpportunityId, isSyncing' + quote_fields + ' from Quote where Id in (' + quoteIds + ')';
            //System.debug(quoteQuery);     
            List<Quote> quotes = Database.query(quoteQuery);
            
            String oppIds = '';    
            Map<Id, Quote> quoteMap = new Map<Id, Quote>();
            
            for (Quote quote : quotes) {
                if (isInsert || (!isInsert && quote.isSyncing)) {
                    quoteMap.put(quote.OpportunityId, quote);
                    if (oppIds != '') oppIds += ', ';
                    oppIds += '\'' + quote.opportunityId + '\'';            
                }
            }
            
            if (oppIds != '') {
                String oppQuery = 'select Id, HasOpportunityLineItem' + opp_fields + ' from Opportunity where Id in (' + oppIds + ')';
                //System.debug(oppQuery);     
                
                List<Opportunity> lstOpp = Database.query(oppQuery);
                List<Opportunity> lstOpp_ForUpdate = new List<Opportunity>();
                List<Quote> lstQuote_ForUpdate = new List<Quote>();        
                
                for (Opportunity opp : lstOpp)
                {
                    Quote quote = quoteMap.get(opp.Id);
                    
                    // store the new quote Id if corresponding opportunity has line items
                    if (isInsert && opp.HasOpportunityLineItem)
                        QuoteSyncUtil.addNewQuoteId(quote.Id);
                    
                    boolean hasChange = false;
                    for (String quoteField : quoteFields)
                    {
                        String oppField = QuoteSyncUtil.getQuoteFieldMapTo(quoteField);Object oppValue = opp.get(oppField);
                        Object quoteValue = quote.get(quoteField);
                        
                        if (oppValue != quoteValue)
                        {                   
                            if (isInsert && (quoteValue == null || (quoteValue instanceof Boolean && !Boolean.valueOf(quoteValue))))
                            {
                                quote.put(quoteField, oppValue);
                                hasChange = true;
                            }
                            else
                            {
                                if (quoteValue == null)
                                    opp.put(oppField, null);
                                else
                                {
                                    opp.put(oppField, quoteValue);
                                    hasChange = true;
                                }
                            }                    
                        }                     
                    }    
                    if (hasChange || Test.isRunningTest())
                    {
                        if (isInsert) 
                            lstQuote_ForUpdate.add(quote);
                        else
                            lstOpp_ForUpdate.add(opp);            
                    }                                  
                } 
                
                if (isInsert)
                    Database.update(lstQuote_ForUpdate);
                else if (!isInsert || Test.isRunningTest())
                {
                    TriggerStopper.stopOpp = true;            
                    Database.update(lstOpp_ForUpdate);
                    TriggerStopper.stopOpp = false;              
                }    
            }
            
            TriggerStopper.stopQuote = false;
        }
    }
    
    //Neha: March 3, 2019 : Partner_Rep_Name__c ,Partner_Rep_Email__c are mandetory if Line Item have Wifi Products
    
    private static void validatePartnerRepInfo(List <Quote > lstQuote , Map<Id, Quote> quoteMap, Map<id, Quote> oldQuoteMap){
        try{
            if(quoteMap!=null && !quoteMap.isEmpty() && quoteMap.keyset()!=null){   
                Map<id, id> mapOpp_mojoLines = new Map<id, id>();         
                list<Quote> lstQt = [Select id,Opportunity.PID__c,Partner_Rep_Name__c,Partner_Rep_Email__c, (Select Product2.Series_Name__c,Product2.Is_MOJO_Product__c, id from QuoteLineItems where product2.Is_Mojo_Product__c = true OR product2.Series_Name__c = 'Wifi' Limit 1) from Quote where Id In: quoteMap.keyset() Limit 49999];
                system.debug('listQuote and product'+lstQt);
                
                if(lstQt!=null && lstQt.size()>0){
                    for(Quote eachQuote : lstQt){
                        if(eachQuote.QuoteLineItems!=null && eachQuote.QuoteLineItems.size()>0)
                            for(QuoteLineItem qli : eachQuote.QuoteLineItems){ 
                                mapOpp_mojoLines.put(eachQuote.id,qli.id);                             
                            }
                    }
                }
                
                System.debug('mapOpp_mojoLines.put(eachQuote.id,oli.id) '+mapOpp_mojoLines);
                System.debug('List Quote '+lstQt);
                if(lstQuote!=null && lstQuote.size()>0){                 
                    for(Quote eachQuote : lstQuote){
                        system.debug('eachQuote.Opportunity.PID__c-----'+eachQuote.Opportunity.PID__c);
                        if(eachQuote.PID__c == 'Yes' && (eachQuote.Partner_Rep_Name__c==null || eachQuote.Partner_Rep_Email__c==null) )
                        {    
                            if(mapOpp_mojoLines!=null && mapOpp_mojoLines.containsKey(eachQuote.id))
                            {     Quote actualRecord = quoteMap.get(eachQuote.Id);
                                  actualRecord.addError('Trg: Both Partner rep name and email are required on partner initiated deals (PID). Please make sure that these fields are filled in before saving the QuoteLineItem');
                            }
                        }
                    }
                }
            }
        }Catch(Exception e){
            System.debug('Error '+e);
            
        }
    } 
    
}