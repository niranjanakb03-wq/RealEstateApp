@isTest
public class MaintenanceRequestHandlerTest {

    @TestSetup
    static void setupData() {
        Vendor__c v1 = new Vendor__c(Name = 'Plumbing Co');
        Vendor__c v2 = new Vendor__c(Name = 'Electric Works');
        insert new List<Vendor__c>{ v1, v2 };

        Properties__c p = new Properties__c(
            Name = 'Test Property',
            Address__c = '10 Ring Road',
            City__c = 'Chennai',
            State__c = 'TN',
            Postal_Code__c = '600001',
            Country__c = 'India',
            Type__c = 'Residential',
            Status__c = 'Available',
            Rent__c = 10000,
            Description__c = 'Test'
        );
        insert p;
    }

    @isTest
    static void testVendorAutoAssigned() {
        Properties__c p = [SELECT Id FROM Properties__c LIMIT 1];

        MaintenanceRequest__c req = new MaintenanceRequest__c(
            Property__c = p.Id,
            Status__c = 'Open',
            Description__c = 'Fix the AC unit'
        );

        Test.startTest();
        insert req;
        Test.stopTest();

        MaintenanceRequest__c inserted = [
            SELECT Vendor__c FROM MaintenanceRequest__c
            WHERE Id = :req.Id
        ];
        System.assertNotEquals(
            null,
            inserted.Vendor__c,
            'Vendor should be auto assigned'
        );
    }

    @isTest
    static void testLeastBusyVendorAssigned() {
        Properties__c p = [SELECT Id FROM Properties__c LIMIT 1];
        Vendor__c v1 = [SELECT Id FROM Vendor__c
                        WHERE Name = 'Plumbing Co' LIMIT 1];

        MaintenanceRequest__c existingReq = new MaintenanceRequest__c(
            Property__c = p.Id,
            Vendor__c = v1.Id,
            Status__c = 'Open',
            Description__c = 'Existing request'
        );
        insert existingReq;

        MaintenanceRequest__c newReq = new MaintenanceRequest__c(
            Property__c = p.Id,
            Status__c = 'Open',
            Description__c = 'New request'
        );

        Test.startTest();
        insert newReq;
        Test.stopTest();

        MaintenanceRequest__c inserted = [
            SELECT Vendor__c FROM MaintenanceRequest__c
            WHERE Id = :newReq.Id
        ];
        Vendor__c v2 = [SELECT Id FROM Vendor__c
                        WHERE Name = 'Electric Works' LIMIT 1];
        System.assertEquals(
            v2.Id,
            inserted.Vendor__c,
            'Less busy vendor should be assigned'
        );
    }

    @isTest
    static void testNoVendors() {
        delete [SELECT Id FROM Vendor__c];

        Properties__c p = [SELECT Id FROM Properties__c LIMIT 1];

        MaintenanceRequest__c req = new MaintenanceRequest__c(
            Property__c = p.Id,
            Status__c = 'Open',
            Description__c = 'No vendors test'
        );

        Test.startTest();
        insert req;
        Test.stopTest();

        MaintenanceRequest__c inserted = [
            SELECT Vendor__c FROM MaintenanceRequest__c
            WHERE Id = :req.Id
        ];
        System.assertEquals(
            null,
            inserted.Vendor__c,
            'Vendor should be null when no vendors exist'
        );
    }
}