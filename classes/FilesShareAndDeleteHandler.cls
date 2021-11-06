public class FilesShareAndDeleteHandler{
    public static void shareFiles(List<ContentDocumentLink> cdlList1){
        Set<Id> documentIdsForUsr = new Set<Id>();
        Set<Id> newDocumentIds = new Set<Id>();
        set<id> push= new set<id>();
		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        CollaborationGroup gp1= [SELECT Id,Name From CollaborationGroup WHERE name ='Files Access'];
        
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocument.title,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:gp1.id];  
        
        for(ContentDocumentLink cdLink:cdl){
            documentIdsForUsr.add(cdLink.ContentDocumentId);  
        } 
        for(ContentDocumentLink cdLink:cdlList1){  
            push.add(cdLink.LinkedEntityId);
        }
       List<ContentDocumentLink> pushl= new List<ContentDocumentLink>([select id,linkedentity.type, contentdocumentid from ContentDocumentLink where linkedentity.type='CASE' and LinkedEntityId= :push]);
        for(ContentDocumentLink cl :pushl){
            system.debug('cdltype  ' +cl.LinkedEntity.type);
            newDocumentIds.add(cl.ContentDocumentId);  
        }

for(Id id : newDocumentIds){
   

            if(!documentIdsForUsr.contains(id)){     
               
                ContentDocumentLink cd = new ContentDocumentLink();
                cd.ContentDocumentId =id;
                cd.LinkedEntityId = gp1.id;
                cd.ShareType = 'C';
                cd.Visibility = 'allusers';
                cdlList.add(cd); 
               system.debug('New Assignment Is being Created');
                
            }
               }
       insert cdlList;
  
    }
    
    
    public static void deleteFiles(list<ContentDocumentLink> oldMapFiles){
        List<contentdocument> FilesToDelete = new List<contentdocument>();
         set<id> CdId = new set<Id>();
        set<id> push=new set<id>();
        for(ContentDocumentLink c : oldMapFiles){
            system.debug('type is' +c.linkedentity.type);
                CdId.add(c.contentdocumentid);
                
                
            
        }
        
        if(CdId.size() > 0){
            system.debug(CdId);
        FilesToDelete = [select id from contentdocument where id in :CdId];
           system.debug(FilesToDelete);
            Database.Delete(FilesToDelete);
           // Database.emptyRecycleBin(FilesToDelete);
            
            system.debug('File deleted');
        }
    }
}