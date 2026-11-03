# Employee payroll using COBOL, JCL and VSAM
EMPLOAD and PAYRUN are the two COBOL programs. PAYDEMO is their run JCL.
IDCAMS is the system utility that allocates the indexed cluster.

## Run in your college lab
1. Place each .cbl in a separate fixed-format source member with the same name. Compile and link both using your college COBOL procedure. Place both executable modules in the load library used in JOBLIB.
2. Put PAYDEMO.jcl in a JCL member. Replace the JOB card and YOURID with your lab settings. Use a NEW test cluster name in the DEFINE and both EMPMAST DDs. The example assumes site-managed storage; if your lab requires an explicit volume or storage class, use your lab's approved allocation values.
3. Submit the job. In SDSF inspect DEFKSDS SYSPRINT and the LOAD and PAY step messages and SYSOUT. Expected step RCs for supplied data: 0, 0 and 4. PAY uses RC 4 to signal rejected time entries.
4. For a second full run choose a fresh cluster name everywhere. To retest only payroll with your populated master, submit a job containing the JOB card, JOBLIB and PAY step with its DDs, omitting the IF/ENDIF wrappers. No deletion is needed.

## Explain the flow
The master row E001IT050 means employee E001, IT department, 50 rupees per hour. KEYS(4 0) sets a four-byte key starting at offset zero. RECORDSIZE(9 9) matches the COBOL FD. EMPLOAD opens the new KSDS for output and writes records in ascending unique key order. A master load error blocks PAYRUN. A failed load can leave a partially populated cluster; start the next full run with a fresh name.
PAYRUN reads time rows in any employee order. For E00108 it sets emp-id to E001, reads the indexed master and computes 8 x 50 = 400. Unknown keys and invalid hours are logged and skipped. Unexpected VSAM failures stop processing with RC 12. This exercise uses two departments and whole rupees. Each time row is a separate pay entry.

## Predict before submitting
- Supplied records: E001 pays 400; E999 is rejected (missing key); E002 pays 240; E003 pays 200; E0020X is rejected (invalid hours). IT 600, HR 240, grand total 840.
- Remove the two rejected time rows. Same totals, PAY RC 0.
- Change E00304 to E00305. IT 650, HR 240, grand total 890.
- Empty TIMEIN with a populated master. All totals zero, PAY RC 0.
These are hand-calculated expectations. Compile and execute on z/OS to obtain actual evidence.
