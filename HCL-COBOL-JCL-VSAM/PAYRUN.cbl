       identification division.
       program-id. PAYRUN.
       environment division.
       input-output section.
       file-control.
           select time-file assign to TIMEIN.
           select emp-file assign to EMPMAST
               organization is indexed access mode is random
               record key is emp-id file status is emp-status.
       data division.
       file section.
       fd time-file recording mode is F.
       01 time-row.
          05 time-id            pic x(4).
          05 time-hours         pic xx.
          05 filler             pic x(74).
       fd emp-file.
       01 emp-row.
          05 emp-id             pic x(4).
          05 emp-dept           pic x(2).
          05 emp-rate           pic 9(3).
       working-storage section.
       01 emp-status            pic xx.
       01 done-flag             pic 9 value 0.
       01 job-rc                pic 99 value 0.
       01 gross-pay             pic 9(5).
       01 it-total              pic 9(12) value 0.
       01 hr-total              pic 9(12) value 0.
       01 grand-total           pic 9(13).
       01 shown-amount          pic z(12)9.
       procedure division.
       main.
           open input emp-file
           if emp-status not = '00'
               display 'OPEN MASTER FAILED ' emp-status
               move 12 to return-code
               goback
           end-if
           open input time-file
           perform until done-flag = 1 or job-rc = 12
               read time-file
                   at end move 1 to done-flag
                   not at end perform process-entry
               end-read
           end-perform
           close time-file
           close emp-file
           if emp-status not = '00'
               display 'CLOSE MASTER FAILED ' emp-status
               move 12 to job-rc
           end-if
           if job-rc < 12 perform print-totals end-if
           move job-rc to return-code
           goback.
       process-entry.
           if time-hours is not numeric or time-hours = '00'
               display 'REJECT ' time-id ' INVALID HOURS'
               move 4 to job-rc
           else
               move time-id to emp-id
               read emp-file
               evaluate emp-status
                   when '00' perform calculate-pay
                   when '23'
                       display 'REJECT ' time-id ' UNKNOWN EMPLOYEE'
                       move 4 to job-rc
                   when other
                       display 'MASTER READ FAILED ' emp-status
                       move 12 to job-rc
               end-evaluate
           end-if.
       calculate-pay.
           compute gross-pay = function numval(time-hours) * emp-rate
           evaluate emp-dept
               when 'IT' add gross-pay to it-total
               when 'HR' add gross-pay to hr-total
               when other
                   display 'INVALID MASTER DEPARTMENT ' emp-dept
                   move 12 to job-rc
                   exit paragraph
           end-evaluate
           move gross-pay to shown-amount
           display time-id ' ' emp-dept ' PAY ' shown-amount.
       print-totals.
           move it-total to shown-amount
           display 'IT TOTAL ' shown-amount
           move hr-total to shown-amount
           display 'HR TOTAL ' shown-amount
           compute grand-total = it-total + hr-total
           move grand-total to shown-amount
           display 'GRAND TOTAL ' shown-amount.
