/*/-----------------------------------------------------------------------------------------------------------------------------------------------------
Creatd By:        Akshay Kumar
Description:      Controller class for trg_Contact  trigger.
Test class:       trg_Contact_test
Histroy:
Modified By:                Description(With reference ticket ):                                                                        Modified Date:
Radhe Shyam                 update all future method in one future.                                                                     Aug 13, 2018
Radhe Shyam                 Added method 'updateCaseWithAccount' to update case Account(Merged another trigger in This Handler)         Aug 29, 2018
Radhe Shyam                 Updated Sharing Code and Portal User/Contact Activate/Deactivate Code (for Admin Access)                    Aug 29, 2018
Radhe Shyam                 Introduced Queueable class to update portal users from Contact; Future method Removed (Admin Access)        Sep 03, 2018
Radhe Shyam                 Updated Sharing Code and Portal User/Contact Activate/Deactivate Code (for Admin Access)                    Sep 06, 2018
Radhe Shyam                 Added 'checkGlobalAccess' Method                                                                            Sep 24, 2018
Radhe Shyam                 Updated Sharing Code and Portal User [CP Phase4-Part1]                                                      Apr 12, 2019
------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
public class trg_ContactHandler {


    public static void invoke_InactiveContactUser(List < Contact > lstContact, List < Contact > lstOldContact, Map < ID, Contact > oldMapContact, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isAfter, Boolean isBefore) {

        Set < Id > setActivePortalUsersContactsID = new set < Id > ();

        Map < String, Integer > mapAccount_SE_PassedQuiz = new Map < String, Integer > ();
        Set < Id > setContactID = new Set < Id > ();
        Map < String, Integer > mapUpdatedAccount = new Map < String, Integer > ();
        Set < Contact > setConACEExam = new Set < Contact > ();
        Set < ID > setOldAccountID_To_Update_TrainedCount = new Set < ID > ();
        Set < ID > setNewAccountID_To_Update_TrainedCount = new Set < ID > ();
        System.debug('---------------------Controller---------runs');
        // Update "# of engineers passed ACE-A" count on associated account.
        Set < Id > setUpdatedCertifiedSECount = new Set < Id > ();
        // Contains Account Id and their count of How many SE's passed "# of engineers passed ACE-A"
        Map < String, Integer > mapAccountIncrease_SE_Passed_ACEExam = new Map < String, Integer > ();
        Map < String, Integer > mapAccountDecrease_SE_Passed_ACEExam = new Map < String, Integer > ();
        Map < String, Integer > mapOldAccountDecrease_SE_Passed_ACEExam = new Map < String, Integer > ();

        if (isInsert || isUpdate) {
            if (lstContact != null && lstContact.size() > 0) {
                for (Contact eachContact: lstContact) {
                    if (isInsert && isAfter) {
                        System.debug('--------Account id on contact------>' + eachContact.Account_ID__c);
                        System.debug('-----------SE passed Quiz or not---->' + eachContact.Partner_Quiz_Passed__c);
                        if (eachContact.Account_ID__c != null && String.isNotEmpty(eachContact.Partner_Quiz_Passed__c) && String.isNotBlank(eachContact.Partner_Quiz_Passed__c) &&
                            eachContact.Partner_Quiz_Passed__c.containsIgnoreCase('passed')) {
                            if (!mapAccount_SE_PassedQuiz.containsKey(eachContact.Account_ID__c))
                                mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, 1);
                            else {
                                Integer intMapTemp = mapAccount_SE_PassedQuiz.get(eachContact.Account_ID__c) + 1;
                                mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, intMapTemp);
                            }
                        }
                    }
                    if (isUpdate) {
                        System.debug('-----------------isAfter------->');
                        // Add contact Id to set.
                        if (isAfter || isBefore) {
                            if (eachContact.InactiveActive_Portal_User__c == true)
                                setContactID.add(eachContact.ID);
                        }

                        if (isAfter) {
                            System.debug('--------------Account ID------------------>' + eachContact.Account_ID__c);
                            System.debug('--------------eachContact.Partner_Quiz_Passed__c------>' + eachContact.Partner_Quiz_Passed__c);
                            System.debug('----------eachContact.of_engineers_passed_ACE_A__c------->' + eachContact.of_engineers_passed_ACE_A__c);
                            System.debug('--------oldMapContact.get(eachContact.Id).of_engineers_passed_ACE_A__c' + oldMapContact.get(eachContact.Id).of_engineers_passed_ACE_A__c);

                            // if "# of engineers passed ACE-A" count value is changed on contact, reflect that count on associated count. 
                            if (eachContact.of_engineers_passed_ACE_A__c != oldMapContact.get(eachContact.Id).of_engineers_passed_ACE_A__c) {
                                System.debug('-------------of_engineers_passed_ACE_A__c--- passed-->' + eachContact.of_engineers_passed_ACE_A__c);
                                // Count How many SE's have passed ACE Exam
                                if (eachContact.of_engineers_passed_ACE_A__c > 0) {
                                    if (!mapAccountIncrease_SE_Passed_ACEExam.containsKey(eachContact.Account_ID__c))
                                        mapAccountIncrease_SE_Passed_ACEExam.put(eachContact.Account_ID__c, 1);
                                    else {
                                        Integer intMapTemp = mapAccountIncrease_SE_Passed_ACEExam.get(eachContact.Account_ID__c) + 1;
                                        mapAccountIncrease_SE_Passed_ACEExam.put(eachContact.Account_ID__c, intMapTemp);
                                    }
                                } else if (eachContact.of_engineers_passed_ACE_A__c == 0) {
                                    if (!mapAccountDecrease_SE_Passed_ACEExam.containsKey(eachContact.Account_ID__c))
                                        mapAccountDecrease_SE_Passed_ACEExam.put(eachContact.Account_ID__c, 1);
                                    else {
                                        Integer intMapTemp = mapAccountDecrease_SE_Passed_ACEExam.get(eachContact.Account_ID__c) + 1;
                                        mapAccountDecrease_SE_Passed_ACEExam.put(eachContact.Account_ID__c, intMapTemp);
                                    }
                                }
                            }

                            //runs when account is changed.
                            if (eachContact.Account_ID__c != oldMapContact.get(eachContact.Id).Account_ID__c) {
                                System.debug('Account is changed------------->' + eachContact.Account_ID__c);

                                // Count How many SE's have passed ACE Exam
                                if (eachContact.of_engineers_passed_ACE_A__c > 0) {
                                    if (!mapAccountIncrease_SE_Passed_ACEExam.containsKey(eachContact.Account_ID__c))
                                        mapAccountIncrease_SE_Passed_ACEExam.put(eachContact.Account_ID__c, 1);
                                    else {
                                        Integer intMapTemp = mapAccountIncrease_SE_Passed_ACEExam.get(eachContact.Account_ID__c) + 1;
                                        mapAccountIncrease_SE_Passed_ACEExam.put(eachContact.Account_ID__c, intMapTemp);
                                    }
                                    if (!mapAccountDecrease_SE_Passed_ACEExam.containsKey(oldMapContact.get(eachContact.Id).Account_ID__c))
                                        mapAccountDecrease_SE_Passed_ACEExam.put(oldMapContact.get(eachContact.Id).Account_ID__c, 1);
                                    else {
                                        Integer intMapTemp = mapAccountDecrease_SE_Passed_ACEExam.get(oldMapContact.get(eachContact.Id).Account_ID__c) + 1;
                                        mapAccountDecrease_SE_Passed_ACEExam.put(oldMapContact.get(eachContact.Id).Account_ID__c, intMapTemp);
                                    }
                                }


                                // if Partner Quiz Status changed to "Passsed"
                                if ((String.isNotBlank(eachContact.Partner_Quiz_Passed__c) && String.isNotEmpty(eachContact.Partner_Quiz_Passed__c) && eachContact.Partner_Quiz_Passed__c.equalsIgnoreCase('passed')) && (String.isEmpty(oldMapContact.get(eachContact.id).Partner_Quiz_Passed__c) || String.isBlank(oldMapContact.get(eachContact.id).Partner_Quiz_Passed__c) ||
                                        !oldMapContact.get(eachContact.id).Partner_Quiz_Passed__c.equalsIgnoreCase('passed'))) {
                                    if (!mapAccount_SE_PassedQuiz.keySet().contains(eachContact.Account_ID__c))
                                        mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, 1);
                                    else {
                                        mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, mapAccount_SE_PassedQuiz.get(eachContact.Account_ID__c) + 1);
                                    }

                                } else if ((String.isBlank(eachContact.Partner_Quiz_Passed__c) || String.isEmpty(eachContact.Partner_Quiz_Passed__c) || !eachContact.Partner_Quiz_Passed__c.equalsIgnoreCase('passed')) && (String.isNotBlank(oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c) && String.isNotEmpty(oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c) &&
                                        oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c.equalsIgnoreCase('passed'))) {
                                    if (!mapAccount_SE_PassedQuiz.keySet().contains(oldMapContact.get(eachContact.Id).Account_ID__c)) {
                                        mapAccount_SE_PassedQuiz.put(oldMapContact.get(eachContact.Id).Account_ID__c, 1);
                                    } else {
                                        mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, mapAccount_SE_PassedQuiz.get(eachContact.Account_ID__c) + 1);
                                    }
                                } else if ((String.isNotBlank(eachContact.Partner_Quiz_Passed__c) && String.isNotEmpty(eachContact.Partner_Quiz_Passed__c) && eachContact.Partner_Quiz_Passed__c.equalsIgnoreCase('passed')) &&
                                    (String.isNotBlank(oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c) && String.isNotEmpty(oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c) && oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c.equalsIgnoreCase('passed'))) {
                                    if (!mapUpdatedAccount.keySet().contains(oldMapContact.get(eachContact.Id).Account_ID__c))
                                        mapUpdatedAccount.put(oldMapContact.get(eachContact.Id).Account_ID__c, 1);
                                    else {
                                        mapUpdatedAccount.put(oldMapContact.get(eachContact.Id).Account_ID__c, mapUpdatedAccount.get(oldMapContact.get(eachContact.Id).Account_ID__c) + 1);
                                    }

                                    if (!mapAccount_SE_PassedQuiz.keySet().contains(eachContact.Account_ID__c))
                                        mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, 1);
                                    else {
                                        mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, mapAccount_SE_PassedQuiz.get(eachContact.Account_ID__c) + 1);
                                    }
                                }
                            }
                            // Only if Partner_Quiz_Passed__c changed to passed.
                            else if (eachContact.Account_ID__c != null && String.isNotEmpty(eachContact.Partner_Quiz_Passed__c) && String.isNotBlank(eachContact.Partner_Quiz_Passed__c) &&
                                eachContact.Partner_Quiz_Passed__c.containsIgnoreCase('passed') && eachContact.Partner_Quiz_Passed__c != oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c) {
                                System.debug('-----------------------eachContact.Partner_Quiz_Passed__c is changed----->' + eachContact.Partner_Quiz_Passed__c);
                                if (!mapAccount_SE_PassedQuiz.keySet().contains(eachContact.Account_ID__c))
                                    mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, 1);
                                else {
                                    mapAccount_SE_PassedQuiz.put(eachContact.Account_ID__c, mapAccount_SE_PassedQuiz.get(eachContact.Account_ID__c) + 1);
                                }
                            }
                            // only if Partner_Quiz_Passed__c is changed to not equals to passed. 
                            else if (eachContact.Account_ID__c != null && (String.isBlank(eachContact.Partner_Quiz_Passed__c) || String.isEmpty(eachContact.Partner_Quiz_Passed__c) || !eachContact.Partner_Quiz_Passed__c.equalsIgnoreCase('passed')) && (String.isNotBlank(oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c) && String.isNotEmpty(oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c) &&
                                    oldMapContact.get(eachContact.Id).Partner_Quiz_Passed__c.equalsIgnoreCase('passed'))) {
                                System.debug('-----------------------eachContact.Partner_Quiz_Passed__c is changed to Null----->' + eachContact.Partner_Quiz_Passed__c);
                                if (!mapUpdatedAccount.keySet().contains(oldMapContact.get(eachContact.Id).Account_ID__c)) {
                                    mapUpdatedAccount.put(oldMapContact.get(eachContact.Id).Account_ID__c, 1);
                                } else {
                                    mapUpdatedAccount.put(eachContact.Account_ID__c, mapUpdatedAccount.get(eachContact.Account_ID__c) + 1);
                                }
                            }
                        }
                    }
                }
            }
            System.debug('-----------mapAccountIncrease_SE_Passed_ACEExam--->' + mapAccountIncrease_SE_Passed_ACEExam);
            System.debug('--------mapAccountDecrease_SE_Passed_ACEExam---->' + mapAccountDecrease_SE_Passed_ACEExam);
            System.debug('----------------------mapUpdatedAccount--->' + mapUpdatedAccount);
            System.debug('-------------------mapAccount_SE_PassedQuiz--->' + mapAccount_SE_PassedQuiz);
            System.debug('---------------setContactID--------->' + setContactID);
            System.debug('-----------setNewAccountID_To_Update_TrainedCount--->' + setNewAccountID_To_Update_TrainedCount);
            System.debug('--------------setOldAccountID_To_Update_TrainedCount----->' + setOldAccountID_To_Update_TrainedCount);
        }

        if (isUpdate && (isAfter || isBefore)) {
            System.debug('----------------->Contact Id----->' + setContactID);

            Map < ID, User > mapContUser = new Map < ID, User > ();
            list < user > lstUser = [select IsActive, id, name, User.contactId from user where user.contactid =: setContactID];

            if (lstUser != null && lstUser.size() > 0) {
                for (User eachUser: lstUser) {
                    mapContUser.put(eachUser.ContactId, eachUser);
                }
            }

            System.debug('--------------------->portal user Id--------------->' + mapContUser);
            Set < Id > setUserId = new Set < Id > ();
            System.debug('---------------> isBefore-->: ' + isBefore + ':-------------:>' + isAfter);
            if (isBefore) {
                for (Contact eachContact: lstContact) {
                    System.debug('--------------- Welcome in isBefore function------------------');
                    // Add contact Id to set.
                    if (eachContact.InactiveActive_Portal_User__c == true && !mapContUser.keySet().contains(eachContact.Id)) {
                        System.debug('---------------------------No Portal User is associated with it.');
                        //eachContact.InactiveActive_Portal_User__c = false;
                        eachContact.InactiveActive_Portal_User__c.addError('No portal user enabled on this contact. So you can\'t check this checkbox.');
                    } else if (eachContact.InactiveActive_Portal_User__c == true && mapContUser.keySet().contains(eachContact.Id)) {
                        if (mapContUser.get(eachContact.Id).IsActive == true) {
                            System.debug('------------------Random Number set to the Link Session field------');
                            // Generate random number.
                            eachContact.Send_Notification_Once__c = false;
                            eachContact.Link_Session__c = String.valueOf((Math.rint(Math.random() * 100000).intValue()));
                            System.debug('Random value generated------------->' + eachContact.Link_Session__c);
                        }
                    }
                }
            }

            if (isAfter) {

            }
        }

        //Incease "# of sales reps passed sales test" count on Account if a SE passed the quiz test.
        if (isAfter && (isInsert || isUpdate)) {
            if (isUpdate) {
                if (mapAccountIncrease_SE_Passed_ACEExam != null && mapAccountIncrease_SE_Passed_ACEExam.size() > 0) {
                    System.debug('----------mapAccountIncrease_SE_Passed_ACEExam---->' + mapAccountIncrease_SE_Passed_ACEExam);
                    List < Account > lstAccount_ToUpdate_PassedQuizSE = new List < Account > ();
                    List < Account > lstAccount = [Select id, of_SE_s_trained__c from Account where ID IN: mapAccountIncrease_SE_Passed_ACEExam.keySet()];
                    System.debug('-----------------of_reps_certified__c of lstAccount------->' + lstAccount);
                    if (lstAccount != null && lstAccount.size() > 0) {
                        for (Account updateAcc: lstAccount) {

                            String strKey = String.valueOf(updateAcc.Id).length() > 15 ? String.valueOf(updateAcc.Id).subString(0, String.valueOf(updateAcc.Id).length() - 3) : updateAcc.Id;
                            System.debug('------ strKey: ' + strKey);
                            if (mapAccountIncrease_SE_Passed_ACEExam.containsKey(strKey)) {
                                Account updatePassedSECount = new Account(Id = updateAcc.id);
                                updatePassedSECount.of_SE_s_trained__c = updateAcc.of_SE_s_trained__c != null ? updateAcc.of_SE_s_trained__c + mapAccountIncrease_SE_Passed_ACEExam.get(strKey) : mapAccountIncrease_SE_Passed_ACEExam.get(strKey);
                                lstAccount_ToUpdate_PassedQuizSE.add(updatePassedSECount);
                            }

                            System.debug('----------updated account---->' + lstAccount_ToUpdate_PassedQuizSE);
                        }

                        if (lstAccount_ToUpdate_PassedQuizSE != null && lstAccount_ToUpdate_PassedQuizSE.size() > 0)
                            update lstAccount_ToUpdate_PassedQuizSE;
                    }
                }

                if (mapAccountDecrease_SE_Passed_ACEExam != null && mapAccountDecrease_SE_Passed_ACEExam.size() > 0) {
                    System.debug('----------mapAccountDecrease_SE_Passed_ACEExam---->' + mapAccountDecrease_SE_Passed_ACEExam);
                    List < Account > lstAccount_ToUpdate_PassedQuizSE = new List < Account > ();
                    List < Account > lstAccount = [Select id, of_SE_s_trained__c from Account where ID IN: mapAccountDecrease_SE_Passed_ACEExam.keySet()];
                    System.debug('-----------------of_reps_certified__c of lstAccount------->' + lstAccount);
                    if (lstAccount != null && lstAccount.size() > 0) {
                        for (Account updateAcc: lstAccount) {
                            String strKey = String.valueOf(updateAcc.Id).length() > 15 ? String.valueOf(updateAcc.Id).subString(0, String.valueOf(updateAcc.Id).length() - 3) : updateAcc.Id;
                            System.debug('------ strKey: ' + strKey);
                            if (mapAccountDecrease_SE_Passed_ACEExam.containsKey(strKey)) {
                                Account updatePassedSECount = new Account(Id = updateAcc.id);
                                updatePassedSECount.of_SE_s_trained__c = updateAcc.of_SE_s_trained__c != null && updateAcc.of_SE_s_trained__c >= mapAccountDecrease_SE_Passed_ACEExam.get(strKey) ? updateAcc.of_SE_s_trained__c - mapAccountDecrease_SE_Passed_ACEExam.get(strKey) : 0;
                                lstAccount_ToUpdate_PassedQuizSE.add(updatePassedSECount);
                            }
                        }

                        System.debug('----------updated account---->' + lstAccount_ToUpdate_PassedQuizSE);

                        if (lstAccount_ToUpdate_PassedQuizSE != null && lstAccount_ToUpdate_PassedQuizSE.size() > 0)
                            update lstAccount_ToUpdate_PassedQuizSE;
                    }

                }
            }


            //This block get runs when account is changed and "of_reps_certified__c" values is changed passed. 
            if (mapAccount_SE_PassedQuiz != null && mapAccount_SE_PassedQuiz.size() > 0) {
                List < Account > lstAccount_ToUpdate_PassedQuizSE = new List < Account > ();
                System.debug('----------------Number of SE passed the quiz----->' + mapAccount_SE_PassedQuiz);
                List < Account > lstAccount = [Select id, of_reps_certified__c from Account where ID IN: mapAccount_SE_PassedQuiz.keySet()];
                System.debug('-----------------of_reps_certified__c of lstAccount------->' + lstAccount);
                if (lstAccount != null && lstAccount.size() > 0) {
                    for (Account updateAcc: lstAccount) {
                        System.debug('------ updateAcc.of_reps_certified__c: ' + updateAcc.of_reps_certified__c + '\n------ mapUpdatedAccount.get(updateAcc.Id): ' + mapUpdatedAccount.get(updateAcc.Id));
                        String strKey = String.valueOf(updateAcc.Id).length() > 15 ? String.valueOf(updateAcc.Id).subString(0, String.valueOf(updateAcc.Id).length() - 3) : updateAcc.Id;
                        System.debug('------ strKey: ' + strKey);
                        if (mapAccount_SE_PassedQuiz.containsKey(strKey)) {
                            Account updatePassedSECount = new Account(Id = updateAcc.id);
                            updatePassedSECount.of_reps_certified__c = updateAcc.of_reps_certified__c != null ? updateAcc.of_reps_certified__c + mapAccount_SE_PassedQuiz.get(strKey) : mapAccount_SE_PassedQuiz.get(strKey);
                            lstAccount_ToUpdate_PassedQuizSE.add(updatePassedSECount);
                        }
                    }

                    System.debug('----------updated account---->' + lstAccount_ToUpdate_PassedQuizSE);

                    if (lstAccount_ToUpdate_PassedQuizSE != null && lstAccount_ToUpdate_PassedQuizSE.size() > 0)
                        update lstAccount_ToUpdate_PassedQuizSE;
                }
            }

            //This block get runs when account name is changed and "of_reps_certified__c" value changed to "failed". 
            if (mapUpdatedAccount != null && mapUpdatedAccount.size() > 0) {
                System.debug('----------------Number of SE passed the quiz----->' + mapUpdatedAccount);
                List < Account > lstAccount_ToUpdate_PassedQuizSE = new List < Account > ();
                List < Account > lstAccount = [Select id, of_reps_certified__c from Account where ID IN: mapUpdatedAccount.keySet()];
                System.debug('-----------------of_reps_certified__c of lstAccount------->' + lstAccount);
                if (lstAccount != null && lstAccount.size() > 0) {
                    for (Account updateAcc: lstAccount) {
                        System.debug('------ updateAcc.of_reps_certified__c: ' + updateAcc.of_reps_certified__c + '\n------ mapUpdatedAccount.get(updateAcc.Id): ' + mapUpdatedAccount.get(updateAcc.Id));
                        String strKey = String.valueOf(updateAcc.Id).length() > 15 ? String.valueOf(updateAcc.Id).subString(0, String.valueOf(updateAcc.Id).length() - 3) : updateAcc.Id;
                        System.debug('------ strKey: ' + strKey);
                        if (mapUpdatedAccount.containsKey(strKey)) {
                            Account updatePassedSECount = new Account(Id = updateAcc.id);
                            System.debug('------ updateAcc.of_reps_certified__c: ' + updateAcc.of_reps_certified__c + '\n------ mapUpdatedAccount.get(updateAcc.Id): ' + mapUpdatedAccount.get(strKey));
                            updatePassedSECount.of_reps_certified__c = updateAcc.of_reps_certified__c != null && updateAcc.of_reps_certified__c >= mapUpdatedAccount.get(strKey) ? updateAcc.of_reps_certified__c - mapUpdatedAccount.get(strKey) : 0;
                            lstAccount_ToUpdate_PassedQuizSE.add(updatePassedSECount);
                        }
                    }

                    System.debug('----------updated account---->' + lstAccount_ToUpdate_PassedQuizSE);

                    if (lstAccount_ToUpdate_PassedQuizSE != null && lstAccount_ToUpdate_PassedQuizSE.size() > 0)
                        update lstAccount_ToUpdate_PassedQuizSE;
                }
            }
        }
    }


    ///=======================================================END =======================================================
    //CR-005906: Method to autopopulate the theater on contact as Mailing country name is insert.
    public Static void PopulateContactRegion(List < Contact > lstContact) {
        for (Contact eachContact: lstContact) {
            AccountCountryRegion__c ObjAccCustom = AccountCountryRegion__c.getInstance(eachContact.MailingCountryCode);
            if (ObjAccCustom != null) {
                eachContact.Theater__c = ObjAccCustom.region__c;
                } else {
                eachContact.Theater__c = '';
            }           
        }
    }

    //Sharing of Case/InstallBase/RMA/Line Itema with Portal User based on Contact Updation(Change in Checkboxes, Change of Account etc.)
    //Written By : Radhe S; Ref: Admin Access
    //Updated on April 12, 2019 [CP Phase4-Part1]
    //=========================== Sharing Start ============================================================
    public static void shareRecords(List < Contact > lstContNew, Map < Id, Contact > mapOldCont) {
        if (lstContNew != null && lstContNew.size() > 0) {

            System.debug('=============== WELCOME TO CONTACT SHARING WORLD ===========');
            //Variables for Case Sharing
            Set < Id > setIdCont_Case = new Set < Id > (); // Is Using for deleting the Case Share
            Map < Id, Id > mapIdContIdAcc_Case = new Map < Id, Id > (); // Is using for inserting the Case Share
            Set < Id > setIdOldAcc_Case = new Set < Id > (); // I using for deleting the Case Share.


            //Variables for RMA and RMA Line Items Sharing
            Set < Id > setIdCont = new Set < Id > (); // Is Using for deleting the RMA and Line Item Share
            Map < Id, Id > mapIdContIdAcc = new Map < Id, Id > (); // Is using for inserting the RMA and Line Item Share
            Set < Id > setIdOldAcc = new Set < Id > (); // I m using for deleting the RMA and Line Item Share.

            //Admin Access
            Set < id > setConIdAllCases = new Set < id > ();
            Map < id, id > MapConId_AccountId_AllCases = new Map < id, id > ();
            Set < id > setAllCasesCon = new Set < id > ();
            Set < id > setParentChildCasesCon = new Set < id > ();
            Set < id > setIBCon = new Set < id > ();
            Set < id > setParentChildIBCon = new Set < id > ();
            Set < id > setUserForDelShare = new set < id > ();
            Set < id > setOldAccountId = new set < id > ();
            Set < id > setAccountToDelShare = new set < id > ();
            Set < id > setAccount_ToDelShareIB = new set < id > ();
            Set < id > setUser_IBDelShare = new Set < id > ();
            boolean flagShareIB ;//= false;
            boolean flagShareCase;// = false;
            //boolean isRMAandCaseShare = false;
            Set < id > setIdOldCont_Del = new Set < id > ();
            Set < id > setIdOldAcc_Del = new Set < id > ();
            Set < id > setAcc_OnAccChange = new Set < id > ();
            Set < id > setCont_OnAccChange = new Set < id > ();
            Set < id > setIdUser = new Set < id > ();
            Set < id > setChildAccToDelShare = new set < id > ();
            Set < id > setIdUserInsert = new Set < id > ();
            boolean isAccountRMA ;//= false;
            boolean isRMAShare;// = false;
            boolean isAccountChanged=false;
            for (Contact eachCont: lstContNew) {
                //Check If Account gets changed
                if (eachCont.AccountId != mapOldCont.get(eachCont.Id).AccountId) {
                    if (eachCont.AccountId != null) {
                        setAcc_OnAccChange.add(eachCont.AccountId);
                        setCont_OnAccChange.add(eachCont.id);
                        mapIdContIdAcc.put(eachCont.Id, eachCont.AccountId);
                        isAccountChanged=true;
                    }
                    if (mapOldCont.get(eachCont.Id).AccountId != null) {
                        setIdOldAcc_Del.add(mapOldCont.get(eachCont.Id).AccountId);
                        setIdOldCont_Del.add(eachCont.Id);
                    }
                }
                //All Cases Change
                if (eachCont.All_Cases__c != mapOldCont.get(eachCont.Id).All_Cases__c) {
                    if (eachCont.AccountId != null && eachCont.All_Cases__c) {
                        mapIdContIdAcc.put(eachCont.Id, eachCont.AccountId);
                        flagShareCase = true;
                        isRMAShare = true;
                    } else if (!eachCont.All_Cases__c && eachCont.AccountId != null) {
                        setIdCont.add(eachCont.Id);
                        setIdOldAcc.add(eachCont.AccountId);
                        setAllCasesCon.add(eachCont.id);
                        flagShareCase = false;
                        isRMAShare = false;
                    }

                }
                //Parent Child Case Change
                if (eachCont.Parent_Child_Cases__c != mapOldCont.get(eachCont.Id).Parent_Child_Cases__c) {
                    if (eachCont.AccountId != null && eachCont.Parent_Child_Cases__c) {
                        flagShareCase = true;
                        isRMAShare = true;
                        mapIdContIdAcc.put(eachCont.Id, eachCont.AccountId);
                    } else if (!eachCont.Parent_Child_Cases__c && eachCont.AccountId != null) {
                        setIdCont.add(eachCont.Id);
                        setParentChildCasesCon.add(eachCont.id);
                        flagShareCase = false;
                        isRMAShare = false;
                    }
                }
                // My I Base Changed
                if (eachCont.Service_Installation_Info__c != mapOldCont.get(eachCont.Id).Service_Installation_Info__c) {
                    if (eachCont.AccountId != null && eachCont.Service_Installation_Info__c) {
                        flagShareIB = true;
                        mapIdContIdAcc.put(eachCont.Id, eachCont.AccountId);
                    } else if (!eachCont.Service_Installation_Info__c && eachCont.AccountId != null) {
                        setIdCont.add(eachCont.Id);
                        setIdOldAcc.add(eachCont.AccountId);
                        setParentChildIBCon.add(eachCont.id);
                        flagShareIB = false;
                    }

                }
                //Parent Child INstall Base Changed
                if (eachCont.Parent_Child_Install_Base_Access__c != mapOldCont.get(eachCont.Id).Parent_Child_Install_Base_Access__c) {
                    if (eachCont.AccountId != null && eachCont.Parent_Child_Install_Base_Access__c) {
                        mapIdContIdAcc.put(eachCont.Id, eachCont.AccountId);
                        flagShareIB = true;

                    } else if (!eachCont.Parent_Child_Install_Base_Access__c && eachCont.AccountId != null) {
                        setIdCont.add(eachCont.Id);
                        setIdOldAcc.add(eachCont.AccountId);
                        setIBCon.add(eachCont.id);
                        flagShareIB = false;

                    }
                }

            }

            System.debug('setIdOldAcc_Del.add(mapOldCont.get(eachCont.Id).AccountId); ' + setIdOldAcc_Del);
            System.debug('setIdOldCont_Del.add(eachCont.Id); ' + setIdOldCont_Del);


            System.debug('setIdCont ' + setIdCont);
            List < User > lstPortalUser = new List < User > ([Select id, ContactId, AccountId from User
                where(ContactId IN: mapIdContIdAcc.keyset() OR ContactId IN: setIdCont OR ContactId IN: setIdOldCont_Del OR ContactId IN: setCont_OnAccChange)
                And isActive = true
            ]);

            System.debug('List Of Users===========> ' + lstPortalUser);
            System.debug('List Of setAcc_OnAccChange===========> ' + setAcc_OnAccChange);
            System.debug('List Of setCont_OnAccChange===========> ' + setCont_OnAccChange);
            System.debug('List Of mapIdContIdAcc===========> ' + mapIdContIdAcc);

            Map < Id, Account > mapIdAcc = new Map < Id, Account > ([Select Id, Global_Access__c, (Select Id, ParentId from ChildAccounts),
                (Select Id, AccountId, All_Cases__c, Parent_Child_Cases__c, Service_Installation_Info__c,
                    Parent_Child_Install_Base_Access__c from Contacts Where(Id IN: mapIdContIdAcc.keyset() OR Id IN: setIdCont))
                from Account
                Where Id IN(Select AccountId from Contact Where(Id IN: mapIdContIdAcc.keyset() or Id IN: setIdCont OR AccountID IN: setAcc_OnAccChange))

            ]);

            //Prepare the Mapdata to share the records

            System.debug('--- mapIdAcc: ' + mapIdAcc);
            Map < Id, List < Id >> mapIdAccListIdUser = new Map < Id, List < Id >> (); //Map key - AccountId and value - List of User's Id
            Map < Id, List < Id >> mapAccWPortalUsr_To_Cases = new Map < Id, List < Id >> ();
            Map < Id, List < Id >> mapIdAccListIdUser_InstallBase = new Map < Id, List < Id >> ();
            Set < id > setChildAccount = new Set < id > ();

            for (User eachUser: lstPortalUser) {
                if (eachUser.ContactId != null && mapIdAcc.containsKey(eachUser.AccountId)) {
                    //Add user in respect of Contact's All Cases checkbox.
                    if (mapIdAcc.get(eachUser.AccountId).Contacts != null && mapIdAcc.get(eachUser.AccountId).Contacts.size() > 0) {
                        for (Contact eachCon: mapIdAcc.get(eachUser.AccountId).Contacts) {
                            //==================== Start of Case, Sharing =================
                            System.debug('for (Contact eachCon: mapIdAcc.get(eachUser.AccountId).Contacts) ' + eachCon);
                            if (eachUser.ContactId == eachCon.Id && eachCon.All_Cases__c) {
                                if (!mapIdAccListIdUser.containsKey(mapIdAcc.get(eachUser.AccountId).Id)) {
                                    mapIdAccListIdUser.put(mapIdAcc.get(eachUser.AccountId).Id, new List < Id > {
                                        eachUser.Id
                                    });
                                    mapAccWPortalUsr_To_Cases.put(mapIdAcc.get(eachUser.AccountId).Id, new List < Id > {
                                        eachUser.Id
                                    });
                                } else {
                                    mapIdAccListIdUser.get(mapIdAcc.get(eachUser.AccountId).Id).add(eachUser.Id);
                                    mapAccWPortalUsr_To_Cases.get(mapIdAcc.get(eachUser.AccountId).Id).add(eachUser.Id);
                                }
                                setIdUserInsert.add(eachUser.id);
                                
                            } else if (eachUser.ContactId == eachCon.Id && eachCon.All_Cases__c == false) {
                                System.debug('I am in All Cases False Section setAccountToDelShare : ' + setAccountToDelShare);
                                System.debug('I am in All Cases False Section setUserForDelShare  : ' + setUserForDelShare);
                                setAccountToDelShare.add(eachCon.Accountid);
                                setUserForDelShare.add(eachUser.id);
                            }
                            //If the related Account have child Accounts then share the cases of these Account's as well
                            if (eachUser.ContactId == eachCon.Id && mapIdAcc.get(eachUser.AccountId).ChildAccounts != null && mapIdAcc.get(eachUser.AccountId).ChildAccounts.size() > 0) {
                                // if (eachCon.Parent_Child_Cases__c == true) {
                                for (Account eachChildAcc: mapIdAcc.get(eachUser.AccountId).ChildAccounts) {
                                    if (eachCon.Parent_Child_Cases__c == true) {
                                        if (!mapAccWPortalUsr_To_Cases.containsKey(eachChildAcc.Id))
                                            mapAccWPortalUsr_To_Cases.put(eachChildAcc.Id, new List < Id > {
                                                eachUser.Id
                                            });
                                        else
                                            mapAccWPortalUsr_To_Cases.get(eachChildAcc.Id).add(eachUser.Id);
                                        setIdUserInsert.add(eachUser.id);
                                    } else if (eachCon.Parent_Child_Cases__c == false) //If we are making Parent Child Case False, get the Id of All Child Accounts
                                    {   setAccountToDelShare.add(eachChildAcc.id);
                                        setUserForDelShare.add(eachUser.id);
                                    }
                                }
                            }

                            //==================== Start of Install Base Switch Information Sharing =================
                            if (eachUser.ContactId == eachCon.Id) {
                                if (eachCon.Service_Installation_Info__c == true) {
                                    //flagShareIB=true;
                                    if (!mapIdAccListIdUser_InstallBase.containsKey(mapIdAcc.get(eachUser.AccountId).Id)) {
                                        mapIdAccListIdUser_InstallBase.put(mapIdAcc.get(eachUser.AccountId).Id, new List < Id > {
                                            eachUser.Id
                                        });
                                    } else {
                                        mapIdAccListIdUser_InstallBase.get(mapIdAcc.get(eachUser.AccountId).Id).add(eachUser.Id);
                                    }
                                } else if (eachCon.Service_Installation_Info__c == false) {
                                    setUser_IBDelShare.add(eachUser.id);
                                    setAccount_ToDelShareIB.add(eachCon.Accountid);
                                }
                            }

                            //If the related Account have child Accounts then share the cases of these Account's as well
                            if (eachUser.ContactId == eachCon.Id && mapIdAcc.get(eachUser.AccountId).ChildAccounts != null && mapIdAcc.get(eachUser.AccountId).ChildAccounts.size() > 0) {
                                for (Account eachChildAcc: mapIdAcc.get(eachUser.AccountId).ChildAccounts) {
                                    if (eachCon.Service_Installation_Info__c == true && eachCon.Parent_Child_Install_Base_Access__c == true) {
                                        if (!mapIdAccListIdUser_InstallBase.containsKey(eachChildAcc.Id))
                                            mapIdAccListIdUser_InstallBase.put(eachChildAcc.Id, new List < Id > {
                                                eachUser.Id
                                            });
                                        else
                                            mapIdAccListIdUser_InstallBase.get(eachChildAcc.Id).add(eachUser.Id);
                                    } else if (eachCon.Parent_Child_Install_Base_Access__c == false) {
                                        setUser_IBDelShare.add(eachUser.id);
                                        setAccount_ToDelShareIB.add(eachChildAcc.Id);
                                        System.debug('IB Del ' + eachCon.Parent_Child_Install_Base_Access__c);
                                    }
                                }
                            }
                        }
                    }

                    //Get the Set of User corresponding to setIdOldAcc_Del -

                    if (setIdOldCont_Del.contains(eachUser.ContactId)) {
                        setUserForDelShare.add(eachUser.id);
                    }
                }
            }



            System.debug('mapAccWPortalUsr_To_Cases  ' + mapAccWPortalUsr_To_Cases);

            System.debug('setUserForDelShare ' + setUserForDelShare);
            System.debug('setAccountToDelShare ' + setAccountToDelShare);

            /*************************************************** START :  CASE SHARING DELETION ****************************/
            // For Deletion of the Sharing for Case
            if (((flagShareCase !=null && !flagShareCase) || isAccountChanged) && setUserForDelShare != null && setUserForDelShare.size() > 0 &&
                ((setAccountToDelShare != null && setAccountToDelShare.size() > 0) || (setIdOldAcc_Del != null && setIdOldAcc_Del.size() > 0)))

            {
                //isRMAandCaseShare=true; //Set True because RMA shareing insertion will run after this.
                System.debug('------------In Case Sharing Delete----------');
                Set < id > accountset_delShare = new Set < id > ();
                if (setAccountToDelShare != null && setAccountToDelShare.size() > 0)
                    accountset_delShare.addAll(setAccountToDelShare);
                if (setIdOldAcc_Del != null && setIdOldAcc_Del.size() > 0)
                    accountset_delShare.addAll(setIdOldAcc_Del);

                BatchCaseSharing objBatchCaseSharing = new BatchCaseSharing();
                String strQuery = objBatchCaseSharing.queryForSharing(null, accountset_delShare, setUserForDelShare, false, false,
                    null, null, 'caseTriggerHelper - createShare: for Deletion of Case Share', null, null, null,null);

                //System.debug('Query for Delete share ' + strQuery);
                if (strQuery != null && strQuery != '') {
                    String strlimit = Label.Admin_Access_Batch_case_sharing_limit_on_contact;
                    if (strlimit != null && strlimit != '') {
                        Integer intimit = Integer.valueOf(strlimit);
                        String jobId = Database.executeBatch(objBatchCaseSharing, intimit);
                        System.debug('--- jobId: ' + jobId);
                        System.debug('======intimit========== ' + intimit);
                    }
                } /************** END : CASE SHARING DELETION ************/
            }
            //RMA Share Deletion : Start
            if (setUserForDelShare != null && setUserForDelShare.size() > 0 &&
                ((setAccountToDelShare != null && setAccountToDelShare.size() > 0) || (setIdOldAcc_Del != null && setIdOldAcc_Del.size() > 0)) &&
                ((isRMAShare!= null && !isRMAShare)    || isAccountChanged)) {
                System.debug('****** START :  RMA SHARING DELETION ***** ');
                System.debug('RS: setIdOldAcc ' + setIdOldAcc);

                if (setUserForDelShare != null && setUserForDelShare.size() > 0)
                    setIdUser.addAll(setUserForDelShare);
                if (setAccountToDelShare != null && setAccountToDelShare.size() > 0)
                    setIdOldAcc.addAll(setAccountToDelShare);
                if (setIdOldAcc_Del != null && setIdOldAcc_Del.size() > 0) //If Account Get Changed
                    setIdOldAcc.addAll(setIdOldAcc_Del);

                System.debug('setIdUser ' + setIdUser);
                System.debug('RS: setIdOldAcc_Del ' + setIdOldAcc_Del);
                System.debug('RS: setIdOldAcc ' + setIdOldAcc);
                System.debug('RS : setAccountToDelShare ' + setAccountToDelShare);


                if ((isRMAShare!=null && !isRMAShare) || isAccountChanged) {
                    String strRMAQuery = 'Select Id, Account_Name__c, (Select Id, RowCause, ParentId, UserOrGroupId from Shares Where RowCause != \'ImplicitChild\' AND UserOrGroupId IN :setIdUser)  from RMADetail__c where ';
                    if (setIdUser != null && setIdUser.size() > 0)
                        strRMAQuery += ' Id IN (Select ParentId from RMADetail__share Where UserOrGroupId IN :setIdUser AND RowCause != \'ImplicitChild\') ';
                    if (setIdOldAcc != null && setIdOldAcc.size() > 0)
                        strRMAQuery += ' AND Account_Name__c IN :setIdOldAcc';

                    System.debug(' strRMAQuery ' + strRMAQuery);
                    if (strRMAQuery != null && strRMAQuery != '') {
                        Batch_ForInstallBase_RMA objBatch = new Batch_ForInstallBase_RMA(strRMAQuery, null, null, setIdOldAcc, setIdUser, true,
                            null, 'cls_InactivePortalUser - shareRecords: for deletion of RMA Share on Contact Object');
                        String strlimit = Label.Admin_Access_delete_RMA_sharing_limit;
                        if (strlimit != null && strlimit != '') {
                            Integer intimit = Integer.valueOf(strlimit);
                            String jobId = Database.executeBatch(objBatch, intimit);
                            System.debug('--- jobId RMA: ' + jobId);
                            System.debug('--- intimit ===== ' + intimit);
                        }
                    }
                }

                if ((isRMAShare!= null && !isRMAShare) || isAccountChanged) {
                    System.debug(' Child RMA Are Sharing ' + isRMAShare);
                    String strRMALineItemQuery = 'Select Id, RMANo__c, RMANo__r.Account_Name__c, (Select Id, RowCause, ParentId, UserOrGroupId from Shares Where RowCause != \'ImplicitChild\' AND UserOrGroupId IN :setIdUser) from RMA_Detail__c where ';
                    if (setIdUser != null && setIdUser.size() > 0)
                        strRMALineItemQuery += ' Id IN (Select ParentId from RMA_Detail__share Where UserOrGroupId IN :setIdUser AND RowCause != \'ImplicitChild\') ';
                    if (setIdOldAcc != null && setIdOldAcc.size() > 0)
                        strRMALineItemQuery += ' AND RMANo__r.Account_Name__c IN :setIdOldAcc';

                    System.debug(' strRMALineItemQuery ' + strRMALineItemQuery);

                    if (strRMALineItemQuery != null && strRMALineItemQuery != '') {
                        Batch_ForInstallBase_RMA objBatch = new Batch_ForInstallBase_RMA(strRMALineItemQuery, null, null, setIdOldAcc, setIdUser, true,
                            null, 'cls_InactivePortalUser - shareRecords: for deletion of RMA Line Item Share on Contact Object');
                        String strlimit = Label.Admin_Access_delete_RMA_sharing_limit;
                        if (strlimit != null && strlimit != '') {
                            Integer intimit = Integer.valueOf(strlimit);
                            String jobId = Database.executeBatch(objBatch, intimit);
                            System.debug('--- jobId: RMA line' + jobId);
                            System.debug('--- intimit ===== ' + intimit);
                        }
                    }
                }
            }
            // Now we have the map  'mapAccWPortalUsr_To_Cases' which is having the following data:
            // 1. It has the Accounts (Parent and Child both) as KEY 
            // 2. List of User ID(with whom we need to share Cases) as Value.

            //Next thing to do is: Fetch the Cases using query where AccountId IN : mapAccWPortalUsr_To_Cases.keyset()

            //==========Start Case Sharing insertion batch ==========
            
            if (((flagShareCase!=null && flagShareCase==true )|| isAccountChanged) && mapAccWPortalUsr_To_Cases != null && mapAccWPortalUsr_To_Cases.size() > 0 &&
                mapAccWPortalUsr_To_Cases.keySet() != null && mapAccWPortalUsr_To_Cases.keySet().size() > 0) {
                System.debug('------------In Case Sharing Insertion----------');
                BatchCaseSharing objBatchCaseSharing = new BatchCaseSharing();
                String strQuery = objBatchCaseSharing.queryForSharing(mapAccWPortalUsr_To_Cases, null, null, true, true,
                    null, null, 'cls_InactivePortalUser - shareRecords: for Insertion of Case Share on Contact Object', null, null, null,null);
                if (strQuery != null && strQuery != '') {
                    //System.debug('--- jobId: Case strQuery ' + strQuery);
                    String strlimit = Label.Admin_Access_Batch_case_sharing_limit_on_contact;
                    if (strlimit != null && strlimit != '') {
                        Integer intimit = Integer.valueOf(strlimit);
                        String jobId = Database.executeBatch(objBatchCaseSharing, intimit);
                        System.debug('--- jobId: Case Insert ' + jobId);
                        System.debug('--- intimit ===== ' + intimit);
                    }

                }
            }

            //End Case Share


            // For Deletion of the Sharing : InstallBase
            System.debug('setUser_IBDelShare===========>setUser_IBDelShare ' + setUser_IBDelShare);
            System.debug('setAccount_ToDelShareIB===========> setAccount_ToDelShareIB ' + setAccount_ToDelShareIB);

            if (setUser_IBDelShare != null && setUser_IBDelShare.size() > 0 &&
                setAccount_ToDelShareIB != null && setAccount_ToDelShareIB.size() > 0 && ((flagShareIB!=null && !flagShareIB) || isAccountChanged)){
                System.debug('------------In InstallBase Sharing Delete----------');
                setIdOldAcc = setAccount_ToDelShareIB;
                setIdUser = setUser_IBDelShare;
                System.debug('setIdUserTemp setIdUserTemp ' + setIdUser);
                System.debug('setAccount_ToDelShareIB ' + setAccount_ToDelShareIB);

                String strQuery = 'Select id, Customer_Name__c, ' +
                    '(Select Id, RowCause, ParentId, UserOrGroupId from Shares Where  RowCause != \'ImplicitChild\')' +
                    ' from NetSuite_NS_Switch_Information__c ' +
                    'where ' +
                    'ID IN (Select ParentId from NetSuite_NS_Switch_Information__Share ' +
                    'Where UserOrGroupId IN :setIdUser AND RowCause != \'ImplicitChild\') AND Customer_Name__c IN :setIdOldAcc';
                // System.debug('Query for Delete share ' + strQuery);
                if (strQuery != null && strQuery != '') {

                    Batch_ForInstallBase_RMA objBatch = new Batch_ForInstallBase_RMA(strQuery, null, null, setIdOldAcc, setIdUser, true,
                        null, 'Sharing_ContactTriggerHandler - Delete IB share on Contact');
                    String jobId = Database.executeBatch(objBatch, 50);
                    System.debug('--- jobId: InstallBase Delete' + jobId);

                }
                setIdUser = new Set < id > ();
                setIdOldAcc = new Set < id > ();
            }

            System.debug('flagShareIB ' + flagShareIB);



            //Calling batch class for sharing the Install Base information
            if (mapIdAccListIdUser_InstallBase != null && mapIdAccListIdUser_InstallBase.size() > 0  && ((flagShareIB!=null && flagShareIB) || isAccountChanged)) {
                System.debug('------------In InstallBase Sharing Insert----------');
                Set < Id > setIdAccount = mapIdAccListIdUser_InstallBase.keySet();
                mapIdAccListIdUser = new Map < Id, List < Id >> ();
                for (Id eachAccId: mapIdAccListIdUser_InstallBase.keySet()) {
                    mapIdAccListIdUser.put(eachAccId, mapIdAccListIdUser_InstallBase.get(eachAccId));
                }

                String strInstallBaseQuery;
                if (setIdAccount != null && setIdAccount.size() > 0) {
                    strInstallBaseQuery = 'Select Id, Customer_Name__c from NetSuite_NS_Switch_Information__c Where Customer_Name__c != null AND Customer_Name__c IN :setIdAccount';
                    //System.debug('---- strInstallBaseQuery: ' + strInstallBaseQuery);

                    if (strInstallBaseQuery != null && strInstallBaseQuery != '') {
                        Batch_ForInstallBase_RMA objBatch = new Batch_ForInstallBase_RMA(strInstallBaseQuery, mapIdAccListIdUser, setIdAccount, null, null, false,
                            null, 'trg_SetContactActiveHelper - share_Case_RMA_IB: for Insertion of Install Base Share on User Object');
                        String jobId = Database.executeBatch(objBatch, 100);
                        System.debug('--- jobId: IB Insert' + jobId);
                    }
                    mapIdAccListIdUser = new Map < Id, List < Id >> ();
                }
            }


            //RMA and Line Sharing Insert
            //Calling batch class for inserting the RMA Share.

            System.debug('mapAccWPortalUsr_To_Cases : ' + json.serialize(mapAccWPortalUsr_To_Cases));
            if (((isRMAShare !=null && isRMAShare )|| isAccountChanged)&& mapAccWPortalUsr_To_Cases != null && mapAccWPortalUsr_To_Cases.size() > 0 && mapAccWPortalUsr_To_Cases != null && mapAccWPortalUsr_To_Cases.size() > 0) {
                System.debug('Start--  RMA SHARING Insert ');
                System.debug('------------In RMA Sharing Insert----------');
                Set < Id > setIdAccount = mapAccWPortalUsr_To_Cases.keySet();

                System.debug('RS : mapAccWPortalUsr_To_Cases.keySet(); ' + mapAccWPortalUsr_To_Cases.keySet());
                System.debug('setIdAccount : ' + setIdAccount);
                String strRMAQuery, strRMALineItemQuery;
                if (setIdAccount != null && setIdAccount.size() > 0) {
                    strRMAQuery = 'Select Id, Account_Name__c from RMADetail__c Where Account_Name__c != null AND Account_Name__c IN :setIdAccount';
                    strRMALineItemQuery = 'Select Id, RMANo__c, RMANo__r.Account_Name__c from RMA_Detail__c Where RMANo__r.Account_Name__c != null AND RMANo__r.Account_Name__c IN :setIdAccount';

                    System.debug('strRMAQuery 1' + strRMAQuery);
                    System.debug('strRMALineItemQuery 1' + strRMALineItemQuery);
                }

                if (strRMAQuery != null && strRMAQuery != '' ){//&& ((isAccountRMA!=null && isAccountRMA) || isAccountChanged)) {
                    System.debug('strRMAQuery 2' + strRMAQuery);
                    Batch_ForInstallBase_RMA objBatch = new Batch_ForInstallBase_RMA(strRMAQuery, mapAccWPortalUsr_To_Cases, setIdAccount, null, null, false,
                        null, 'trg_SetContactActiveHelper - share_Case_RMA_IB: for Insertion of RMA Share on User Object');
                    String jobId = Database.executeBatch(objBatch);
                    System.debug('--- jobId: ' + jobId);
                }
                System.debug('setIdUserInsert 1: '+setIdUserInsert);
                if (strRMALineItemQuery != null && strRMALineItemQuery != '' ){//&& ((isRMAShare !=null && isRMAShare) || isAccountChanged)) {
                    System.debug('setIdUserInsert 2: '+setIdUserInsert);
                    System.debug('strRMALineItemQuery 2' + strRMALineItemQuery);
                    Batch_ForInstallBase_RMA objBatch = new Batch_ForInstallBase_RMA(strRMALineItemQuery, mapAccWPortalUsr_To_Cases, setIdAccount, null, null, false,
                        null, 'trg_SetContactActiveHelper - share_Case_RMA_IB: for Insertion of RMA Line Item on User Object.');
                    String jobId = Database.executeBatch(objBatch, 100);
                    System.debug('--- jobId: ' + jobId);
                }
            }


        }
        System.debug('=============== BYE BYE FROM CONTACT SHARING WORLD ===========');
    }

    //=============================END Sharing: Aug 9 2018 =========================================


    public static void activatePortalUser(List < Contact > lstContact, List < Contact > lstOldContact,
        Map < ID, Contact > oldMapContact, Boolean isInsert, Boolean isUpdate,
        Boolean isDelete, Boolean isAfter, Boolean isBefore) {
        System.debug('My New Method called for activate portal user');
        Set < Id > setConId_PermanentInactive = new Set < Id > ();
        Set < Id > setConId_TemporaryInactive = new Set < Id > ();
        
        for (Contact con: lstContact) {
            If(con.InactiveActive_Portal_User__c != oldMapContact.get(con.Id).InactiveActive_Portal_User__c) {
                setConId_PermanentInactive.add(con.Id);              
            }
            If(con.Temporarily_Inactive__c != oldMapContact.get(con.Id).Temporarily_Inactive__c) {
                setConId_TemporaryInactive.add(con.Id);              
            }
        }       
        //Enqueue the Job for User Update with Active/Inactive Checkbox
        if (cls_StaticFlagVariable.count < 1) {           
            cls_StaticFlagVariable.count++; 
            if (!cls_StaticFlagVariable.isContactUpdatedFromUser && ((setConId_PermanentInactive != null && setConId_PermanentInactive.size() > 0) 
                                                                 || (setConId_TemporaryInactive != null && setConId_TemporaryInactive.size() > 0  ))) {
                Queueable_UpdateUser myQueueable = new Queueable_UpdateUser(setConId_PermanentInactive,setConId_TemporaryInactive, 'From Contact Trg Handler');
                ID jobID = System.enqueueJob(myQueueable);
                System.debug('JOB ID FOR Queueable_UpdateUser ' + jobId);
            }
        }

        System.debug('End ----------  Method "activatePortalUser()" in trg_ContactHandler');
    }

    /*
    Event: Before Update;
    Added By: Radhe S; Date: Aug 29, 2018; Desc: Update Account On Related Case If Account is Updated on Contact
    Added By: Radhe S, Date: Sep 6, 2018;  Desc: Update the RecordType of Contact based on the Active/Inactive Portal User
        
    */
    public static void updateCaseWithAccount(List < Contact > lstContact, Map < id, Contact > oldMap, Map < id, Contact > newMap) {
        List < Case > lstCase_forUpdate = new List < Case > ();
        Set < id > setContact = new Set < id > ();
        String CON_RECORD_TYPES_ID_MASTER = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('MasterRecordType').getRecordTypeId();
        String CON_RECORD_TYPES_ID_READONLY = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Read Only Record Type').getRecordTypeId();
        System.debug('If Portal U check box is False ' + CON_RECORD_TYPES_ID_MASTER);
        System.debug('If Portal U check box is False ' + CON_RECORD_TYPES_ID_READONLY);
        
        for (Contact con: lstContact) {
            if ((oldMap.get(con.Id).AccountID != newMap.get(con.Id).AccountID)) {
                if(newMap.get(con.Id).AccountID != Null){
                    setContact.add(con.id);
                }
                con.Customer_Portal_Profile_Access__c= 'Standard User';
                
            }


             //IF Changing any of Checkbox
            if(oldMap.get(con.id).InactiveActive_Portal_User__c != con.InactiveActive_Portal_User__c  
                || oldMap.get(con.id).Temporarily_Inactive__c != con.Temporarily_Inactive__c )
            {
                if(oldMap.get(con.id).InactiveActive_Portal_User__c ==False &&  con.InactiveActive_Portal_User__c == True){ //if this changed True from False,mean Is_Temporarily_Inactive__c should be false.
                     con.Temporarily_Inactive__c =false;
                     con.Customer_Portal_Profile_Access__c='';
                     con.RecordTypeId = CON_RECORD_TYPES_ID_READONLY;
                     // Added By Sazid Ali .**** For tracking Permanent InAcive user ******** 2018-10-05
                     if(cls_StaticFlagVariable.lstForTrackingInactiveUser[1] == 'true' || cls_StaticFlagVariable.lstForTrackingInactiveUser[2] == 'true')
                     {
                        cls_StaticFlagVariable.lstForTrackingInactiveUser[1] = 'false';
                        cls_StaticFlagVariable.lstForTrackingInactiveUser[2] = 'false';
                     }else
                     {
                        cls_StaticFlagVariable.lstForTrackingInactiveUser[0] = 'true'; 
                        con.User_Deactivated_From__c = 'Contact';
                     }
                }else if(oldMap.get(con.id).InactiveActive_Portal_User__c ==True && con.InactiveActive_Portal_User__c == FALSE){
                    //Update Record Type 
                    if(oldMap.get(con.id).Temporarily_Inactive__c == True && con.Temporarily_Inactive__c == FALSE || con.Temporarily_Inactive__c == FALSE){
                        con.RecordTypeId = CON_RECORD_TYPES_ID_MASTER;
                    }
                     if(con.Request_Status__c=='Approved'){
                       con.Customer_Portal_Profile_Access__c = 'Admin User';
                    }else 
                       con.Customer_Portal_Profile_Access__c = 'Standard User';
                }else if(oldMap.get(con.id).Temporarily_Inactive__c == False && con.Temporarily_Inactive__c ==TRUE){
                    con.InactiveActive_Portal_User__c =false;
                    con.RecordTypeId = CON_RECORD_TYPES_ID_READONLY;
                    if(con.Request_Status__c=='Approved'){  //RS: added later
                       con.Customer_Portal_Profile_Access__c = 'Admin User';
                    }else 
                       con.Customer_Portal_Profile_Access__c = 'Standard User';
                    
                    //con.Customer_Portal_Profile_Access__c='';
                }else if(oldMap.get(con.id).Temporarily_Inactive__c == True && con.Temporarily_Inactive__c == FALSE){
                    //Update Record Type
                    con.RecordTypeId = CON_RECORD_TYPES_ID_MASTER;
                     if(con.Request_Status__c=='Approved'){
                       con.Customer_Portal_Profile_Access__c = 'Admin User';
                    }else 
                       con.Customer_Portal_Profile_Access__c = 'Standard User';
                }
                if(con.Temporarily_Inactive__c == false && con.InactiveActive_Portal_User__c == false){
                    if(con.Request_Status__c=='Approved'){
                       con.Customer_Portal_Profile_Access__c = 'Admin User';
                    }else 
                       con.Customer_Portal_Profile_Access__c = 'Standard User';
                }
            }

        }

        //Update Case's Account based on Contact's Account
        for (Case c: [Select id, AccountID, contactID from Case where contactID IN: setContact]) {
            c.AccountId = newMap.get(c.ContactId).AccountId;
            lstCase_forUpdate.add(c);
        }
        if (lstCase_forUpdate != null && lstCase_forUpdate.size() > 0)
            update lstCase_forUpdate;

    }
      // Check for ediatble user access 
    // Added by Sazid Ali
    public static void editableAccess(List<Contact> lstConNew, Map<Id,Contact> mapConOld)
    {
        
        if(lstConNew != null && lstConNew.size() > 0)
        {
            Set<Id> setGrpUsrId = new Set<Id>();
            Group grp = [SELECT Id FROM Group Where Name = 'Public Group Admin Access Editable Users'];
            System.debug('grp ==========='+grp);
            if(grp != null && grp.Id != null)
            {
                List<GroupMember> lstGm = [SELECT Id, UserOrGroupId FROM GroupMember Where groupId =: grp.Id];
                if(lstGm != null && lstGm.size() > 0)
                {
                    for(GroupMember gm : lstGm)
                        setGrpUsrId.add(gm.UserOrGroupId); 
                }
                System.debug('lstGm ==========='+lstGm);
            }
            System.debug('setGrpUsrId ==========='+setGrpUsrId);
            Map<Id,Account> mapAcc = new Map<Id,Account>([Select Id, Name from Account Where OwnerId =: userInfo.getUserId()]);
            Profile pro = [SELECT Id FROM Profile Where Name='Customer Portal Manager'];
            User usr = [Select Id, profileId from User Where Id =: UserInfo.getUserId()]; 
            System.debug('mapAcc ==========='+mapAcc);
            for(Contact con : lstConNew)
            {
                if((con.Customer_Portal_Profile_Access__c != mapConOld.get(con.Id).Customer_Portal_Profile_Access__c) || 
                   (con.All_Cases__c != mapConOld.get(con.Id).All_Cases__c) || (con.Parent_Child_Cases__c != mapConOld.get(con.Id).Parent_Child_Cases__c) || 
                   (con.Request_Status__c != mapConOld.get(con.Id).Request_Status__c) || 
                   (con.Service_Installation_Info__c != mapConOld.get(con.Id).Service_Installation_Info__c) || 
                   (con.Parent_Child_Install_Base_Access__c != mapConOld.get(con.Id).Parent_Child_Install_Base_Access__c) || 
                   (con.InactiveActive_Portal_User__c != mapConOld.get(con.Id).InactiveActive_Portal_User__c) 
                   ){
                       if((mapAcc != null && mapAcc.size() > 0 && mapAcc.containsKey(con.accountId)) || 
                          (setGrpUsrId != null && setGrpUsrId.size() > 0 && setGrpUsrId.contains(UserInfo.getUserId())) ||
                          (pro != null && pro.Id == usr.ProfileId) || (cls_StaticFlagVariable.flagForEditableAccess == false) ||
                          (trgAccountHandler.isFromAcc == true)
                         ){
                              System.debug('You have permission. Enjoy!!!');
                              cls_StaticFlagVariable.flagForEditableAccess = true;
                          }else
                          {
                               con.addError('You don\'t have permission to edit any of the field under "Customer Portal Access" section.');
                           }   
                   }
            }     
        }
        
    }
    
    
     /*Admin Accees - POST UAT Requirement
    ---------------------------------------
    This Methods Runs when Customer_Portal_Profile_Access__c being changed on Contact.
    If It is changed to 'Admin User' for some Contact , this contact will be populated on Related Account's First_Admin_Contact__c field .
    If this value is other than 'Admin User', then First_Admin_Contact__c will be blank.
    */
    public Static void PopulateFirstAdminOnAccount(List<Contact> lstContact, Map<id,Contact> oldMap) 
    {
        System.debug('Inside PopulateFirstAdminOnAccount method');
        Map<id,Id> mapConId_AccId_ForDeactivate = new Map<id,Id>();
        Map<id,Id> mapConId_AccId_ForRe_activate = new Map<id,Id>();
        Map<id,id>  MapContactId_AccountId = new Map<id,id>();
        Map<id,id>  MapContactId_AccountId_del = new Map<id,id>();
        // for set null in account
        Map<id,id>  MapContactId_AccounIdForNull = new Map<id,id>();    
        // for set another value in account
        Map<id,id>  MapContactId_AccounIdForAnother = new Map<id,id>(); 
        
        for(Contact eachContact: lstContact)
        {  
            if(eachContact.Customer_Portal_Profile_Access__c != oldMap.get(eachContact.id).Customer_Portal_Profile_Access__c)
            {
                // When contact change STD user to Admin
                if(eachContact.Customer_Portal_Profile_Access__c == 'Admin User' && eachContact.AccountId != null)
                {
                    System.debug('Inside Admin user '+eachContact.id +' === '+eachContact.AccountId);
                    MapContactId_AccountId.put(eachContact.id,eachContact.AccountId);
                }
                // When Admin to STD user
                if(eachContact.Customer_Portal_Profile_Access__c !='Admin User' && eachContact.AccountId != null)
                {
                    MapContactId_AccountId_del.put(eachContact.id,eachContact.AccountId);
                }
            }       
            // When Admin user will deactivate  
            if(((eachContact.InactiveActive_Portal_User__c == true && oldMap.get(eachContact.id).InactiveActive_Portal_User__c == false) || 
                    (eachContact.Temporarily_Inactive__c == true && oldMap.get(eachContact.id).Temporarily_Inactive__c == false)) && oldMap.get(eachContact.id).Customer_Portal_Profile_Access__c == 'Admin User' && eachContact.AccountId != null)
            {
                mapConId_AccId_ForDeactivate.put(eachContact.id,eachContact.AccountId);
            }
            // When Admin user will Re-Activate 
            if(((eachContact.InactiveActive_Portal_User__c == false && oldMap.get(eachContact.id).InactiveActive_Portal_User__c == true) || 
                    (eachContact.Temporarily_Inactive__c == false && oldMap.get(eachContact.id).Temporarily_Inactive__c == true)) && eachContact.Customer_Portal_Profile_Access__c =='Admin User' && eachContact.AccountId != null)
            {
                mapConId_AccId_ForRe_activate.put(eachContact.id,eachContact.AccountId);
            }
            // If change accountid at contact which is admin user
            if(eachContact.AccountId != oldMap.get(eachContact.Id).AccountId && eachContact.Customer_Portal_Profile_Access__c == 'Admin User' && oldMap.get(eachContact.id).Customer_Portal_Profile_Access__c == 'Admin User')
            {
                    MapContactId_AccounIdForNull.put(eachContact.id,oldMap.get(eachContact.Id).AccountId);
                    MapContactId_AccounIdForAnother.put(eachContact.id,eachContact.AccountId);
            }
        }
        System.debug('=================After for loop================ '+mapConId_AccId_ForDeactivate );
        // Method calling for fill contact id to Acc
        if(MapContactId_AccountId != null && MapContactId_AccountId.size() > 0)
        {
            fillConInfoOnAcc(MapContactId_AccountId);
        }
        // Method calling for fill contact id to Acc
        if(MapContactId_AccountId_del != null && MapContactId_AccountId_del.size() > 0)
        {
            //fillNullOnAcc(MapContactId_AccountId_del);
            fillConInfoOnAccOrNull(MapContactId_AccountId_del);
        }
        // Method calling for fill contact id to Acc if Active another one otherwise set NULL
        if(mapConId_AccId_ForDeactivate != null && mapConId_AccId_ForDeactivate.size() > 0)
        {
            System.debug('----------------Beofre fillConInfoOnAccOrNull aclling----------------------');
            fillConInfoOnAccOrNull(mapConId_AccId_ForDeactivate);
        }   
        // Method calling for fill contact id to Acc if Re-Active Admin user, When no one present Admin user otherwise No changes
        if(mapConId_AccId_ForRe_activate != null && mapConId_AccId_ForRe_activate.size() > 0)
        {
            fillConInfoOnAccForReActive(mapConId_AccId_ForRe_activate);
        }
        
        // method calling for null
        if(MapContactId_AccounIdForNull != null && MapContactId_AccounIdForNull.size() > 0)
        {
            fillConInfoOnAccOrNull(MapContactId_AccounIdForNull);
        }
        // method calling for another value
        if(MapContactId_AccounIdForAnother != null && MapContactId_AccounIdForAnother.size() > 0)
        {
            fillConInfoOnAccForReActive(MapContactId_AccounIdForAnother);
        }
    }        
            
        public static void fillConInfoOnAcc(Map<Id,Id> MapContactId_AccountId)
        {
            //Now Update the new 
            System.debug('MapContactId_AccountId '+MapContactId_AccountId);
            //Get the Accounts related to contacts
            List<Account> lstAccount = new List<Account>([Select id, First_Admin_Contact__c,
                                                            (Select id,Customer_Portal_Profile_Access__c 
                                                            from Contacts 
                                                            where Customer_Portal_Profile_Access__c = 'Admin User' 
                                                            AND AccountId IN: MapContactId_AccountId.values() 
                                                            AND InactiveActive_Portal_User__c = false
                                                            AND Temporarily_Inactive__c = false
                                                            ORDER BY Admin_User_Updated_Time__c ASC 
                                                            LIMIT 1) 
                                                        From Account 
                                                        WHERE Id IN: MapContactId_AccountId.values()
                                                        AND (First_Admin_Contact__c = null OR First_Admin_Contact__c = '')]);
                                                        
            List<Account> lstAccountToUpdate = new List<Account>(); 
            System.debug('lstAccount  '+lstAccount);
            if(lstAccount!=null && lstAccount.size()>0)
            {
                for(Account acc : lstAccount)
                {
                    for(Contact c: acc.Contacts)
                    {
                        Account a = new Account();
                        a.id = acc.id;
                        a.First_Admin_Contact__c = c.id;
                        lstAccountToUpdate.add(a);                      
                    }
                    
                }
            }
            System.debug('lstAccountToUpdate  '+lstAccountToUpdate);
            if(lstAccountToUpdate!=null && lstAccountToUpdate.size()>0)
               try{ 
                    update lstAccountToUpdate;
                    System.debug('================Update successful==============');
               }Catch(Exception e){
                   System.debug('e.getMessage()==========='+e.getMessage());
              }        
            
        }
    
    // For Reactivate portal user.
    public static void fillConInfoOnAccForReActive(Map<Id,Id> MapContactId_AccountId)
        {
            //Now Update the new 
            System.debug('MapContactId_AccountId '+MapContactId_AccountId);
            //Get the Accounts related to contacts
            List<Account> lstAccount = new List<Account>([Select id, First_Admin_Contact__c,
                                                            (Select id,Customer_Portal_Profile_Access__c 
                                                            from Contacts 
                                                            where Customer_Portal_Profile_Access__c = 'Admin User' 
                                                            AND AccountId IN: MapContactId_AccountId.values() 
                                                            AND InactiveActive_Portal_User__c = false
                                                            AND Temporarily_Inactive__c = false
                                                            ORDER BY Admin_User_Updated_Time__c ASC 
                                                            LIMIT 1) 
                                                        From Account 
                                                        WHERE Id IN: MapContactId_AccountId.values()
                                                        ]);
                                                        
            List<Account> lstAccountToUpdate = new List<Account>(); 
            System.debug('lstAccount  '+lstAccount);
            if(lstAccount!=null && lstAccount.size()>0)
            {
                for(Account acc : lstAccount)
                {
                    for(Contact c: acc.Contacts)
                    {
                        Account a = new Account();
                        a.id = acc.id;
                        a.First_Admin_Contact__c = c.id;
                        lstAccountToUpdate.add(a);                      
                    }
                    
                }
            }
            System.debug('lstAccountToUpdate  '+lstAccountToUpdate);
            if(lstAccountToUpdate!=null && lstAccountToUpdate.size()>0)
               try{ 
                    update lstAccountToUpdate;
                    System.debug('================Update successful==============');
               }Catch(Exception e){
                   System.debug('e.getMessage()==========='+e.getMessage());
              }        
            
        }
    
   
        // For Deactivate Admin portal user
        public static void fillConInfoOnAccOrNull(Map<Id,Id> MapContactId_AccountId)
        {
            //Now Update the new 
            System.debug('MapContactId_AccountId '+MapContactId_AccountId);
            //Get the Accounts related to contacts
            List<Account> lstAccount = new List<Account>([Select id, First_Admin_Contact__c,
                                                            (Select id,Customer_Portal_Profile_Access__c 
                                                            from Contacts 
                                                            where Customer_Portal_Profile_Access__c = 'Admin User' 
                                                            AND AccountId IN: MapContactId_AccountId.values() 
                                                            AND InactiveActive_Portal_User__c = false
                                                            AND Temporarily_Inactive__c = false
                                                            ORDER BY Admin_User_Updated_Time__c ASC 
                                                            LIMIT 1) 
                                                        From Account 
                                                        WHERE Id IN: MapContactId_AccountId.values() AND First_Admin_Contact__c IN: MapContactId_AccountId.keySet() ]);
                                                        
            List<Account> lstAccountToUpdate = new List<Account>(); 
            System.debug('lstAccount  '+lstAccount);
            if(lstAccount!=null && lstAccount.size()>0)
            {
                for(Account acc : lstAccount)
                {
                    if(acc.Contacts != null && acc.Contacts.size() > 0)
                    {   
                        for(Contact c: acc.Contacts)
                        {
                            Account a = new Account();
                            a.id = acc.id;
                            a.First_Admin_Contact__c = c.id;
                            lstAccountToUpdate.add(a);                      
                        }
                    }else
                    {
                        Account a = new Account();
                        a.id = acc.id;
                        a.First_Admin_Contact__c = null;
                        lstAccountToUpdate.add(a);                      
                    }
                }
            }
            System.debug('lstAccountToUpdate  '+lstAccountToUpdate);
            if(lstAccountToUpdate!=null && lstAccountToUpdate.size()>0)
               try{ 
                    update lstAccountToUpdate;
               }Catch(Exception e){
                   System.debug('lstAccountToUpdate '+lstAccountToUpdate);
              }        
            
        }
        
        
        //Before Insert: Update All Case and Parent Child Cases True on Contactif related Account Global Access is true.
        //Added By Radhe S. Ref: Admin Access. Date: 24 Sep 2018
        public static void checkGlobalAccess(List<Contact> lstContact){
        
            String PARTNER = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            String END_USER = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        
            Set<id> setAccountId = new Set<id>();
            for(Contact eachContact : lstContact){
                if(eachContact.AccountId!=null){
                    setAccountId.add(eachContact.AccountId);
                    }
            }       
            
            if(setAccountId!=null && setAccountId.size()>0){
                Map<id, Account> mapAccount = new Map<id, Account>([Select id, Global_Access__c,RecordTypeId from Account 
                                               where Id IN : setAccountId AND Global_Access__c = true]);
                                                                           
                
                    for(Contact eachCon : lstContact){
                        if(mapAccount!=null && mapAccount.size()>0 
                        && mapAccount.containsKey(eachCon.AccountId) && mapAccount.get(eachCon.AccountId).Global_Access__c==true ){
                            System.debug('mapAccount.get(eachCon.AccountId).RecordType.Name '+ mapAccount.get(eachCon.AccountId).RecordTypeid  + ' ' +PARTNER + '__ '+END_USER);
                            if(mapAccount.get(eachCon.AccountId).RecordTypeId == END_USER){                            
                                eachCon.All_Cases__c = true;
                                eachCon.Parent_Child_Cases__c =true;
                            }else if(mapAccount.get(eachCon.AccountId).RecordTypeId == PARTNER){
                                eachCon.All_Cases__c = true;
                            }
                        }                                                              
                    }
            }       
        }
        
    //Added by Neha to update opportunity Contact field:21 feb:CR-007450 
    public static void updateOpportunity(List<Contact> lstContact){
    Map<id,id> mapAcc = new Map<id,id>();
        for(Contact eachCon: lstContact){
            if(!mapAcc.containskey(eachCon.AccountId))
                mapAcc.put(eachCon.AccountId, eachCon.id);
        }
        
        //Get the List of Account and Related Opportunity
        if(mapAcc!=null && mapAcc.size()>0){
            List<Account> lstAccount = new List<Account>();
            lstAccount = [Select id, (Select Contact__c, ContactRole__c from Opportunities where Contact__c=null) from Account where Id In :mapAcc.keyset()];
            if(lstAccount!=null && lstAccount.size()>0){
            List<Opportunity> lstOpportToUpdate = new List<Opportunity>();
                for(Account acc: lstAccount){
                    if(acc.opportunities !=null && acc.opportunities.size()>0){
                        for(Opportunity eachOpp : acc.opportunities){
                            if(mapAcc!= null && mapAcc.containsKey(acc.id)){
                                Opportunity opp = new Opportunity(id=eachOpp.id);
                                opp.Contact__c = mapAcc.get(acc.id);
                                opp.ContactRole__c = 'Business User';
                                lstOpportToUpdate.add(opp);
                            }
                        }
                    }
                }
                
                //Update opportunity list
                if(lstOpportToUpdate!=null && lstOpportToUpdate.size()>0){
                    try{                    
                        Database.Update(lstOpportToUpdate, false); 
                        System.debug('update successful');
                    }catch(Exception e){
                        System.debug('e.getMessage()===========' + e.getMessage());
                    }
                }
            
            }
        }
    }
    
}