public class CommentsController {
    public List<Activity_Comment__c> commentList{get;set;}
    public string URLEditComment{get;set;}
    public id CommentId{get;set;}
    public Id activityId{get;set;}
    public Id IdNew{get;set;}
    public String URLNewComment{get;set;}
    Public String Label{get;set;}
    public String auto{get;set;}
    
    public CommentsController(){
        activityId =  ApexPages.currentPage().getParameters().get('Id');
         Label=System.Label.ProjectActivity;
        IdNew = ApexPages.currentPage().getParameters().get('id');
        system.debug('IdNew------>'+IdNew);
        auto = [Select Name from Activity__c where id = :IdNew].Name;
        System.debug('lstName'+auto);
       URLNewComment= System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+'a4b/e?'+Label+'='+auto;
        system.debug('CommentId====>>'+CommentId);
        
        
    
    }
    //System.debug('activityId'+activityId);
   /* public String EditComment() {
        // CommentId = ApexPages.currentPage().getParameters().get('CommentId_d');
        String test= ApexPages.currentPage().getParameters().get('CommentId_d');
         system.debug('tes====>>'+test);
        URLEditComment = System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+test+'/e?retURL=%2F'+activityId;
        system.debug('URLEditComment=='+URLEditComment);
        //PageReference reference = new PageReference(URLEditComment);
        //reference.setRedirect(true);

        return URLEditComment;

    }*/


    public List<Activity_Comment__c> getComments() {
        commentList = [select Comment_Description__c,CreatedBy.Name,CreatedDate from Activity_Comment__c where Project_Activity__c = :activityId];
        system.debug('commentList==='+commentList);
        return commentList;
    }
    
    
   /* public PageReference NewComment() {
        IdNew = ApexPages.currentPage().getParameters().get('id');
        system.debug('IdNew------>'+IdNew);
        string auto = [Select Name from Activity__c where id = :IdNew].Name;
        System.debug('lstName'+auto);
       URLNewComment= System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+'a4b/e?CF00N5C000004JIIR='+auto;
      System.debug('URLNewComment'+URLNewComment);
        PageReference pageRef = new PageReference(URLNewComment);
        pageRef.setredirect(true);
        return null;
        //return URLNewComment;
    }*/
    public PageReference deleteComment() {
           CommentId = ApexPages.currentPage().getParameters().get('CommentId_d');
            system.debug('CommentId--->'+CommentId);
            //list<Activity_Comment__c> obj= [select id,Comment_Description__c from Activity_Comment__c where id=: CommentId];
            //system.debug('obj===>'+obj);
            database.delete(CommentId);
            //delete obj;
        
        //PageReference pageRef = new PageReference('/'+activityId);
       // pageRef.setredirect(true);
        return null;
       
    }


}