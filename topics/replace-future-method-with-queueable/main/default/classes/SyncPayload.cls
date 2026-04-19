public with sharing class SyncPayload {
    public List<Account> accounts;
    public String source;
    public Boolean notify;
    public Integer retryCount;

    public SyncPayload(List<Account> accounts, String source, Boolean notify) {
        this.accounts = accounts;
        this.source = source;
        this.notify = notify;
        this.retryCount = 0;
    }
}

