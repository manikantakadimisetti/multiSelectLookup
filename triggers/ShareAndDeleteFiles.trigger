trigger ShareAndDeleteFiles on ContentDocumentLink (after insert, after delete) {
    
   If(trigger.IsInsert && trigger.IsAfter){
        System.debug('Calling Share files Method');
        FilesShareAndDeleteHandler.shareFiles(trigger.new);
    }

    if (trigger.isafter && trigger.isDelete) {
    system.debug('Triggerd on Content Doc link');
        FilesShareAndDeleteHandler.deleteFiles(trigger.old);
        system.debug(trigger.old);
    }

   
}