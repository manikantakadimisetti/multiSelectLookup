public class TestingApprovalProcess {
    
    
    public static void initApprovalProcess(List<Id> sObjectIdList,List<Id> assignToIds) {
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        for (Id sObjectId : sObjectIdList) {
            for (Id asigneId : assignToIds) {
                //Class to submit a record for approval.
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                //Sets the comments to be added to the approval request
                approvalRequest.setComments('Submitting request for approval.');
                //Sets the ID of the record to be submitted for approval. For example, it can specify
                // an account, contact, or custom object record.
                approvalRequest.setObjectId(sObjectId);
                //If the next step in your approval process is another Apex approval process, you specify
                // exactly one user ID as the next approver. If not, you cannot specify a user ID and this
                // method must be null
                approvalRequest.setNextApproverIds(new List<Id>{asigneId});
                
                approvalRequestList.add(approvalRequest);
            }
        }
        Approval.process(approvalRequestList);
    }
    
    
    public static void SetNextApprover(Id sObjectId, String action, String commentFromApprover,List<Id> assignToIds) {
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
            Integer i=0;
        if (action == 'Approve') { 
            for (ProcessInstanceWorkitem workItem : getProcessInstanceWorkItems(sObjectId)) {
                for (Id directorUserId : assignToIds) {
                    approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, directorUserId, action, commentFromApprover+String.valueOf(i)));
                    i++;
                }
            }
        } else if (action == 'Reject' || action == 'Removed') {
            for (ProcessInstanceWorkitem workItem : getProcessInstanceWorkItems(sObjectId)) {
                approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, null, action, commentFromApprover+String.valueOf(i)));
                i++;
            }
        }
        Approval.process(approvalRequestList);
    }
    
    
    
    public static void FinalApproval(Id sObjectId, String action, String comment) {
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
            Integer i=0;
        for(ProcessInstanceWorkitem approvalProcessWorkingItem : getProcessInstanceWorkItems(sObjectId)) {
            approvalRequestList.add(createProcessWorkItemRequest(approvalProcessWorkingItem.Id, null, action, comment+String.valueOf(i)));
            i++;
        }
        Approval.process(approvalRequestList);
    }
    
    
    //Helper method get Process Instance Work Items which represents a user’s pending approval request.
    private static List<ProcessInstanceWorkitem> getProcessInstanceWorkItems(Id objectId) {
        return [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: objectId];
    }
    
    //Helper method to create new Process Work Item Request record to process an approval request after it is submitted.
    private static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, Id approverId, String approvalAction, String commentFromApprover){
        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
        result.setComments(commentFromApprover);
        result.setAction(approvalAction);
        result.setWorkitemId(approvalStepId);
        if (approverId != null) {
            result.setNextApproverIds(new List<Id>{approverId});
        }
        return result;
    }
    
    
    
    
    
    
    
    
    
}