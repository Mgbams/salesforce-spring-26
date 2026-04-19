public with sharing class Step1Job implements Queueable {

    private List<Account> accounts;

    public Step1Job(List<Account> accounts) {
        this.accounts = accounts;
    }

    public void execute(QueueableContext context) {
        for (Account acc : accounts) {
            acc.Description = 'Step 1 complete';
        }
        update accounts;

        System.enqueueJob(new Step2Job(accounts));
    }
}

