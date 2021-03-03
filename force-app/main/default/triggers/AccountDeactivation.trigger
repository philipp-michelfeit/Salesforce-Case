trigger AccountDeactivation on Account (before update) {
    for (Account account : Trigger.new) {
        if( account.IsActive__c ){
            // Feld InactiveSince löschen
            account.InactiveSince__c = null;
        } else {
            // Account.InactiveSince__c = Aktuelles Datum + jetzige Uhrzeit
            Datetime currentDateAndTime = Datetime.now();
            account.InactiveSince__c = currentDateAndTime;

            // Alle Contact Records von dem Account sollen geupdated werden mit “Contact.HasOptedOutOfEmail” = TRUE
            List<Contact> contacts = new List<Contact>([SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Account.Id =: account.Id]);

            try {

                for( Contact contact : contacts ){
                    contact.HasOptedOutOfEmail = true;
                }

                update contacts;

            } catch ( Exception e ) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }

            // Verify E-Mail optout update
            List<Contact> contactsToVerify = new List<Contact>([SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Account.Id =: account.Id]);
            
            for( Contact vc : contactsToVerify ){
                System.assertEquals(true, vc.HasOptedOutOfEmail);
            }
            
            // Alle Opportunity Records von dem Account, die “Opportunity.IsClosed = FALSE” sind, sollen auf StageName = “Lost” gesetzt werden
            List<Opportunity> opportunities = new List<Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Account.Id =: account.Id AND IsClosed = false]);

            try {

                for( Opportunity opportunity : opportunities ){
                    opportunity.StageName = 'Lost';
                }

                update opportunities;

            } catch ( Exception e ) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }

            // Verify Opportunities update
            List<Opportunity> opportunitiesToVerify = [SELECT Id, StageName FROM Opportunity WHERE Account.Id =: account.Id AND IsClosed = false];
            
            for( Opportunity vo : opportunitiesToVerify ){
                System.assertEquals('Lost', vo.StageName);
            }
        } 
    }
}