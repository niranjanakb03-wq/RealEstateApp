public with sharing class MaintenanceRequestHandler {

    public static void assignVendor(List<MaintenanceRequest__c> newRequests) {

        List<Vendor__c> allVendors = [SELECT Id FROM Vendor__c];
        if (allVendors.isEmpty()) return;

        Map<Id, Integer> vendorWorkload = new Map<Id, Integer>();
        for (Vendor__c v : allVendors) {
            vendorWorkload.put(v.Id, 0);
        }

        List<AggregateResult> workloads = [
            SELECT Vendor__c vendorId, COUNT(Id) requestCount
            FROM MaintenanceRequest__c
            WHERE Status__c IN ('Open', 'In Progress')
              AND Vendor__c != null
            GROUP BY Vendor__c
        ];

        for (AggregateResult ar : workloads) {
            Id vendorId = (Id) ar.get('vendorId');
            Integer count = (Integer) ar.get('requestCount');
            if (vendorWorkload.containsKey(vendorId)) {
                vendorWorkload.put(vendorId, count);
            }
        }

        Id leastBusyVendor = null;
        Integer lowestCount = 999999;

        for (Id vendorId : vendorWorkload.keySet()) {
            if (vendorWorkload.get(vendorId) < lowestCount) {
                lowestCount = vendorWorkload.get(vendorId);
                leastBusyVendor = vendorId;
            }
        }

        for (MaintenanceRequest__c req : newRequests) {
            if (req.Vendor__c == null && leastBusyVendor != null) {
                req.Vendor__c = leastBusyVendor;
            }
        }
    }
}