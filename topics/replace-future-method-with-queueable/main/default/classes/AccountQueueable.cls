public with sharing class AccountQueueable implements Queueable {

    private List<Account> accounts;

    public AccountQueueable(List<Account> accounts) {
        this.accounts = accounts;
    }

    public void execute(QueueableContext context) {
        for (Account acc : accounts) {
            acc.Name += ' - Updated';
        }
        update accounts;
    }
}
