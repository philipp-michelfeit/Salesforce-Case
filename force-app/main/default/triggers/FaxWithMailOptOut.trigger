trigger FaxWithMailOptOut on Contact (before update) {
    for ( Contact contact : Trigger.new ){
        if ( contact.HasOptedOutOfFax ){
            contact.HasOptedOutOfEmail = true;
        }
    }
}