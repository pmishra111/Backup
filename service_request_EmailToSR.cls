/**
* Email services are automated processes that use Apex classes
* to process the contents, headers, and attachments of inbound
* email.
Created By Radhe Shyam - For Serivce Request Functionality: Email Service Class
*/
global class service_request_EmailToSR implements Messaging.InboundEmailHandler {
    public Service_Request__c SR;
    boolean Isreopening = false;
    public boolean isSpecialEmailSender = false;
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        //Check Different Parameters of InboundEmail
        System.debug('Email :FromName will be'+ email.fromName);
        System.debug('Email :inReplyTo ' + email.inReplyTo);
        System.debug('Email :headers ' + email.Headers);
        System.debug('Email Subject'+email.Subject);
        System.debug('Email From Address'+email.fromAddress);
        System.debug('Email :messageId ' + email.messageId);
        System.debug('Email :references ' + email.references);
        boolean isTrialExpirad = false;
        String EmailSubject = email.fromAddress.toLowerCase();
        System.debug('Email Subject String is'+EmailSubject);
        SR_CustomSettings__c cs;
        cs = SR_CustomSettings__c.getInstance('SR_Details');
        List<String> lstExcludedEmail;
        List<String> lstExcludedEmail1;
        if(cs.Excluded_Email__c != null)
            lstExcludedEmail = cs.Excluded_Email__c.split(',');
        if(cs.Excluded_Email1__c	!= null)
            lstExcludedEmail1 = cs.Excluded_Email1__c.split(',');
        
        
        String subject = email.subject;
        String srNumber = '';
        if (subject.contains('SR-0')) {
            srNumber = subject.substring(subject.IndexOf('[S') - 10, subject.IndexOf('[') - 1);
        }	
        
        System.debug('List of Exculded Mail'+lstExcludedEmail);
        System.debug('List of Excluded Mail'+lstExcludedEmail1);
        if(cs !=null && cs.Disable_SR__c==false && (((lstExcludedEmail != null && !lstExcludedEmail.contains(EmailSubject)) && (lstExcludedEmail1 !=null && !lstExcludedEmail1.contains(EmailSubject))) || ((lstExcludedEmail != null && !lstExcludedEmail.contains(EmailSubject)) && (lstExcludedEmail1 ==null)) || ((lstExcludedEmail ==null) && (lstExcludedEmail1 !=null && !lstExcludedEmail1.contains(EmailSubject))  )))    
        { 
            System.debug('IF CS not equal to null');
            List<String> lstReference = email.references;
            List < Service_Request__c > lstExistingSR;
            if(lstReference != null)
                lstExistingSR = new list < Service_Request__c > ([select Inbound_Message_Id__c, id from Service_Request__c where Inbound_Message_Id__c IN: lstReference OR Name =:srNumber ]);
            System.debug('List of Existing Service Request'+lstExistingSR);
            if(lstExistingSR!=null && lstExistingSR.size()>0) {
                Set < string > refIds = new set < String > ();
                refIds.addAll(email.references);
                System.debug('Set values  ' + refIds);
                createCommentForExistingServiceRequest(refIds, email);
            }
            else{
                System.debug('Got null reference');
                createNewServiceRequest(email);
            }
            
        }
        
        result.success = true;
        return result;
    }
    
    public void createNewServiceRequest(Messaging.InboundEmail email) {
        //Access Custom Setting for checking Special Email
        string subject = email.subject;
        string fromaddress = email.fromAddress;
        if (email.fromAddress != null) {
            System.debug('=========Check Email From Address=============' + email.fromaddress);
            isSpecialEmailSender = service_request_Util.checkSpecialSender(email.fromAddress); //If returns true, system wil not send any notification to anyone.
        }
        
        list < Service_Request__c > SRR = new list < Service_Request__c > ();
        Service_Request__c c = new Service_Request__c();
        SR_CustomSettings__c cs;
        list < User > u = new list < User > ();
        System.debug('email.fromAddress========' + email.fromAddress);
        if (email.fromAddress != null) {
            try {
                cs = SR_CustomSettings__c.getInstance('SR_Details');
                if (service_request_Util.getUserIDFromEmail(email.fromAddress).id != null) {
                    c.Requested_By_Email__c = email.fromAddress;
                    c.OwnerId = service_request_Util.getUserIDFromEmail(email.fromAddress).id; //u.id;
                } else {
                    c.Requested_By_Email__c = email.fromAddress;
                    cs = SR_CustomSettings__c.getInstance('SR_Details');
                    If(cs != null && cs.Manager_Email__c != null)
                        c.OwnerId = service_request_Util.getUserIDFromEmail(cs.Manager_Email__c).id; //uId.id;      
                    
                }
                try {
                    String strUserQry = 'Select  id, email, Department from User where Email=:fromaddress';
                    System.debug('========StrUserQuery============' + strUserQry);
                    if (cs != null && cs.Is_Portal_Enabled_Org__c == true) {
                        strUserQry += ' and IsPortalEnabled=false ';
                    }
                    strUserQry += ' Limit 1';
                    System.debug('=========StrUserQuery last===========' + strUserQry);
                    u = Database.query(strUserQry);
                    if (u != null && u[0].department != null) {
                        c.Department__c = u[0].department;
                        System.debug('======Department is=======' + c.department__c);
                    } else
                        c.Department__c = ' ';
                } catch (exception e) {
                    System.debug('======Msg DEPTT Error========' + e.getMessage());
                }
                
            } catch (Exception e) {
                System.debug('======Inside Catch Method=======');
                System.debug('MSG ERROR ' + e.getMessage());
            }
        }
        
        if (email.htmlbody != null) {
            if ((email.htmlbody).length() > service_request_CONSTANTS.MAXSIZE_OF_DESCRIPTION)
                c.Description__c = (email.htmlbody).substring(0, service_request_CONSTANTS.MAXSIZE_OF_DESCRIPTION);
            else
                c.Description__c = email.htmlbody;
        } else
            c.Description__c = '';
        
        if (isSpecialEmailSender) {
            c.KRac_Request_From_Special_Sender__c = true;
            c.Priority__c = service_request_CONSTANTS.ESCALATED_PRIORITY;
        } else {
            c.KRac_Request_From_Special_Sender__c = false;
            c.Priority__c = service_request_CONSTANTS.DEFAULT_PRIORITY;
        }
        c.Status__c = service_request_CONSTANTS.DEFAULT_STATUS;
        c.Subject__c = email.subject;
        c.Requested_By_Email__c = (email.fromAddress).trim();
        String toEmailIds = '';
        if (String.Valueof(email.toAddresses) != null && String.Valueof(email.toAddresses) != '')
            toEmailIds = String.Valueof(email.toAddresses);
        SR_CustomSettings__c cs1 = SR_CustomSettings__c.getInstance('SR_Details');
        //  if (cs1 != null && cs1.SupportEmailID__c != '' && cs1.SupportEmailID__c != null)
        //    toEmailIds = toEmailIds.replace(')', ',' + cs1.SupportEmailID__c + ')');
        c.Additional_Email_To__c = toEmailIds;
        c.Additional_Email__c = String.Valueof(email.ccAddresses);
        //c.OwnerId = queueGrp.id; 
        c.KRac_Org_Name__c = service_request_CONSTANTS.DEFAULT_AFFACTED_ORG;
        c.KRac_Case_Created_From__c = service_request_CONSTANTS.EMAIL;
        c.KRac_Primary_Email__c = (email.fromAddress).trim();
        c.Inbound_Message_Id__c = email.messageId;
        SRR.add(c);
        
        try {
            system.debug('before insert  --- ' + c);
            
            
            
            /** Insert all of the newly created Share records and capture save result **/
            Database.SaveResult[] srList = Database.insert(SRR, false);
            for (Database.SaveResult sr: srList) {
                if (sr.isSuccess()) {
                    // Save attachments, if any
                    list < Attachment > listAttch = new list < Attachment > ();
                    if (email.textAttachments != null) {
                        
                        for (Messaging.Inboundemail.TextAttachment tAttachment: email.textAttachments) {
                            Attachment attachment = new Attachment();
                            attachment.Name = tAttachment.fileName;
                            attachment.Body = Blob.valueOf(tAttachment.body);
                            attachment.ParentId = sr.Id;
                            listAttch.add(attachment);
                            
                        }
                    }
                    if (email.binaryAttachments != null) {
                        for (Messaging.Inboundemail.BinaryAttachment bAttachment: email.binaryAttachments) {
                            Attachment attachment = new Attachment();
                            attachment.Name = bAttachment.fileName;
                            attachment.Body = bAttachment.body;
                            attachment.ParentId = sr.Id;
                            listAttch.add(attachment);
                        }
                    }
                    
                    try {
                        if (listAttch != null && listAttch.size() > 0)
                            insert listAttch;
                    } catch (Exception e) {
                        service_request_Util.CreateErrorLog(e, True, email);
                        System.debug('Attachment Insertion Failed under Ticket, Sending from Email');
                    }
                }
            }
            
        } catch (Exception e) {
            System.debug('e==================' + e);
            service_request_Util.CreateErrorLog(e, true, email); 
        }
        if (SRR[0].id != null) {
            
            Attachment attach = new Attachment();
            attach.Name = 'SR_ON_CREATE_DETAILS' + '.html';
            Blob bodyBlob = Blob.valueOf(email.htmlbody);
            attach.body = bodyBlob;
            attach.parentId = SRR[0].id;
            try {
                insert attach;
            } catch (Exception e) {
                service_request_Util.CreateErrorLog(e, true, email);
                
            }
            service_request_Util.SendEmailToAllContactsWhenNewCaseCreated(SRR[0], email.fromAddress, isSpecialEmailSender);
        }
    }
    
    private void createCommentForExistingServiceRequest(Set < String > refIds, Messaging.InboundEmail email) {
        //Get the Subject of incoming Email
        String subject = email.subject;
        String srNumber = '';
        if (subject.contains('SR-0')) {
            srNumber = subject.substring(subject.IndexOf('[S') - 10, subject.IndexOf('[') - 1);
        }
        
        List < Service_Request__c > lstExistingSRs = new list < Service_Request__c > ([select Inbound_Message_Id__c, id, Name, KRac_Primary_Email__c, Status__c, Description__c, SR_Closed_Date__c, Subject__c, Additional_Email__c, Additional_Email_To__c, Requested_By_Email__c from Service_Request__c where Inbound_Message_Id__c IN: refIds OR Name =: srNumber]);
        
        if (lstExistingSRs != null && lstExistingSRs.size() > 0) {
            if (lstExistingSRs[0].Inbound_Message_Id__c == null || lstExistingSRs[0].Inbound_Message_Id__c == '') {
                Service_Request__c sr = new Service_Request__c(id = lstExistingSRs[0].id);
                sr.Inbound_Message_Id__c = email.inReplyTo;
                update sr;
            }
            
            System.debug('Comment Under Existing Case ');
            List < Ticket_Comment_New__c > CommentList = new list < Ticket_Comment_New__c > ();
            Ticket_Comment_New__c newComment = new Ticket_Comment_New__c();
            newComment.Change_Request_Defect__c = lstExistingSRs[0].id;
            try {
                //list<User> u = new List<User>();
                User u = new User();
                if (email.fromAddress != null) {
                    u = service_request_Util.getUserIDFromEmail(email.fromAddress);
                    if (u != null) {
                        newComment.Comment_Added_By_Email__c = u.FirstName + ' ' + u.LastName;
                        newComment.Comment_Added_By__c = u.FirstName + ' ' + u.LastName + '(' + email.fromAddress + '); ' + System.Now();
                    } else {
                        newComment.Comment_Added_By_Email__c = email.fromAddress;
                        newComment.Comment_Added_By__c = email.fromAddress + '; ' + System.Now(); //For ticket created by System user - will handle using Trigger in Comment Trigger
                    }
                    
                }
            } catch (Exception e) {
                System.debug('Error in comment ' + e.getMessage());
            }
            
            newComment.Is_Closing_Comment__c = service_request_CONSTANTS.NEW_COMMENT;
            //Check for Email Body size, if Description Field is too large, Email Service will show error like this - See Link (https://prnt.sc/gyt0lk)
            if (email.htmlBody != null) {
                if ((email.htmlBody).length() > service_request_CONSTANTS.MAXSIZE_OF_DESCRIPTION) {
                    newComment.Comment_Update_Remarks__c = (email.htmlBody).substring(0, service_request_CONSTANTS.MAXSIZE_OF_DESCRIPTION);
                } else newComment.Comment_Update_Remarks__c = email.htmlBody;
            } else newComment.Comment_Update_Remarks__c = '';
            
            newComment.Comment_Source__c = service_request_CONSTANTS.EMAIL;
            CommentList.add(newComment);
            try {
                Database.SaveResult[] CommentListInserted = Database.insert(CommentList, false);
                for (Database.SaveResult sr: CommentListInserted) {
                    if (sr.isSuccess()) {
                        
                        // Save attachments, if any
                        list < Attachment > listAttch = new list < Attachment > ();
                        if (email.textAttachments != null) {
                            
                            for (Messaging.Inboundemail.TextAttachment tAttachment: email.textAttachments) {
                                Attachment attachment = new Attachment();
                                system.debug('I am in attachment Section');
                                attachment.Name = tAttachment.fileName;
                                attachment.Body = Blob.valueOf(tAttachment.body);
                                attachment.ParentId = sr.Id;
                                listAttch.add(attachment);
                                //system.debug('before insert  --- ' +c);
                            }
                        }
                        if (email.binaryAttachments != null) {
                            for (Messaging.Inboundemail.BinaryAttachment bAttachment: email.binaryAttachments) {
                                Attachment attachment = new Attachment();
                                
                                attachment.Name = bAttachment.fileName;
                                attachment.Body = bAttachment.body;
                                attachment.ParentId = sr.Id;
                                listAttch.add(attachment);
                            }
                        }
                        
                        try {
                            if (listAttch != null && listAttch.size() > 0)
                                insert listAttch;
                        } catch (Exception e) {
                            service_request_Util.CreateErrorLog(e, true, email);
                            System.debug('Attachment Insertion Failed under Ticket, Sending from Email');
                        }
                    }
                }
                //System.debug('Inserted  + '+newComment);
            } catch (Exception e) {
                service_request_Util.CreateErrorLog(e, True, email);
            }
        } else {
            System.debug('No Ref ID');
        }
    }
}