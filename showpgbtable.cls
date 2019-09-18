public class showpgbtable {
    public PO__c InsPo{get;set;}
    public list<po__c> acc1 = new list<po__c>();
    public integer Amount1{get;set;}
    public integer Amount2{get;set;}
    public date startDate1{get;set;}
    public string startDate2{get;set;}
    public Boolean rendered{set;get;}
    public string strKey {get;set;}
    public boolean check{get;set;}
    // public string query;
    public showpgbtable(ApexPages.StandardController controller){ //constructor
        check=false;
        //Accountlist();
        rendered =false;
        InsPo = new po__c() ;       
        system.debug('Amount1===>>>'+Amount1);
        system.debug('Amount2===>>>'+Amount2);
    }
    public pageReference Accountlist(){
        try{
            string query = 'select id,Name,Amount__c,Project_Name__c,Manager_Name__c,(SELECT Id,ParentId,Name FROM Attachments) from po__c ';
            if(Amount1 != null && Amount2 != null && Amount2 != 0 && Amount1 != 0 )
            {
                query += 'Where Amount__c >='+ Amount1 + ' AND Amount__c <=' + Amount2 ;
            }
            else
            {
                if(Amount1 != null && Amount1 != 0)
                { query += ' Where Amount__c >='+ Amount1 ;}
                else
                { if(Amount2 != null && Amount2 != 0)  
                {query += 'Where Amount__c <='+ Amount2 ;}  }       
                
            }
            
            system.debug('InsPo.Date__c===>>'+InsPo.Date__c);
            system.debug('InsPo.Date2__c===>>'+InsPo.Date2__c);
            IF(InsPo.Date__c != null &&  InsPo.Date2__c!=null)
            {
                
                if(query.contains('Where Amount__c') && Amount1!=0)
                {
                    query += ' AND DAY_ONLY(createddate) >=' + string.valueOf(InsPo.Date__c).remove('00:00:00')+  ' AND DAY_ONLY(createddate) <='+string.valueOf(InsPo.Date2__c).remove('00:00:00');
                }
                else  if(query.contains('Where Amount__c') && Amount1!=0)
                {
                    query += ' where DAY_ONLY(createddate) >= ' + string.valueOf(InsPo.Date__c).remove('00:00:00')+' where DAY_ONLY(createddate) <= ' + string.valueOf(InsPo.Date2__c).remove('00:00:00');
                }
            }
            
            if(check == true && (query.contains('Amount__c') || query.contains('DAY_ONLY(createddate)') ))
            {
                String w = '%'+strKey+'%';
                try{
                    query+=' AND (Name like : w OR Manager_Name__c like : w OR Project_Name__c like : w)limit 1000';
                }
                catch(exception e){
                    System.debug('Error====>'+e);
                }
            }     
            
            
            system.debug('query===>>'+query);
            acc1 = database.query(query);
            //========================================
            
            
            
            rendered  = true; 
            return null;
        }catch(exception e){
            return null;
        }
        
    }
    public void search()
    {
        system.debug('strKey'+strKey);
        if( strKey != null && strKey !=''  )
        {
            
            check = true;
            Accountlist();
        }
        else
        {
            Accountlist();
        }
        
    }
    public list<Po__c> getaccounts(){
        acc1.sort();
        return acc1;
    }
}