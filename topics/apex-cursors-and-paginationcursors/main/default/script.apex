Integer totalToCreate = 4000;
Integer batchSize = 200; // max per insert
Integer created = 0;

for (Integer offset = 0; offset < totalToCreate; offset += batchSize) {

    List<Case> casesToInsert = new List<Case>();

    Integer currentBatchSize = Math.min(batchSize, totalToCreate - offset);

    for (Integer i = 1; i <= currentBatchSize; i++) {
        Integer seq = offset + i;

        casesToInsert.add(new Case(
            Subject = 'CURSOR-DEMO-CASE-' + String.valueOf(seq).leftPad(4, '0'),
            Origin  = 'Phone',
            Status  = 'New', // Open status
            Priority = 'Medium',
            Description = 'Generated for Apex Cursor pagination testing. Seq=' + seq
        ));
    }

    insert casesToInsert;
    created += casesToInsert.size();

    System.debug('Inserted cases so far: ' + created);
}

System.debug('DONE. Total open cases created: ' + created);
