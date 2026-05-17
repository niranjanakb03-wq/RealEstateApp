trigger MaintenanceRequestTrigger on MaintenanceRequest__c (before insert) {
    MaintenanceRequestHandler.assignVendor(Trigger.new);
}