public without sharing class LeadProcessor implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext dbc){
        return Database.getQueryLocator([SELECT Id, Name FROM Lead]);
    }

    public void execute(Database.BatchableContext dbc, List<Lead> leads){
        for (Lead l : leads){
            l.LeadSource = 'Dreamforce';
        }
        update leads;
    }

    public void finish(Database.BatchableContext dbc){
        system.debug('Success!');
    }

}

//Test Method
@isTest
public with sharing class LeadProcessorTest {
    @isTest
    public static void testBatchClass() {
        //Load test data
        List<Lead> lstLead = new List<Lead>();
        for(Integer i=0; i<200;i++){
            lstLead.add(new Lead(LastName='Borges', Company='Salesforce'));
        }
        insert lstLead;

        //Perform the test
        Test.startTest();
        LeadProcessor lp = new LeadProcessor();
        Id batchId = Database.executeBatch(lp, 200);
        Test.stopTest();

        //Check the results
        List<Lead> updateLeads = [SELECT Id FROM Lead WHERE LeadSource = 'Dreamforce'];
        System.assertEquals(200, updateLeads.size(), 'Error: at least 1 record not updated correctly');

    }
}
