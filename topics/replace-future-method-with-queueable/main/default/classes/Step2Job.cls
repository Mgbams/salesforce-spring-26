public with sharing class Step2Job implements Queueable, Database.AllowsCallouts {

    private List<Account> accounts;

    public Step2Job(List<Account> accounts) {
        this.accounts = accounts;
    }

    public void execute(QueueableContext context) {
        Http http = new Http();

        for (Account acc : accounts) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.example.com/accounts/' + acc.Id);
            req.setMethod('POST');

            HttpResponse res = http.send(req);
            System.debug('Response: ' + res.getStatusCode());
        }
    }
}
