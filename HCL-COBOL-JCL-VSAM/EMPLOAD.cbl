       identification division.
       program-id. EMPLOAD.
       environment division.
       input-output section.
       file-control.
           select seed-file assign to SEEDIN.
           select emp-file assign to EMPMAST
               organization is indexed access mode is sequential
               record key is emp-id file status is emp-status.
       data division.
       file section.
       fd seed-file recording mode is F.
       01 seed-row              pic x(80).
       fd emp-file.
       01 emp-row.
          05 emp-id             pic x(4).
          05 emp-dept           pic x(2).
          05 emp-rate           pic 9(3).
       working-storage section.
       01 emp-status            pic xx.
       01 done-flag             pic 9 value 0.
       01 job-rc                pic 99 value 0.
       procedure division.
       main.
           open output emp-file
           if emp-status not = '00'
               display 'OPEN MASTER FAILED ' emp-status
               move 12 to return-code
               goback
           end-if
           open input seed-file
           perform until done-flag = 1 or job-rc > 0
               read seed-file
                   at end move 1 to done-flag
                   not at end perform load-employee
               end-read
           end-perform
           close seed-file
           close emp-file
           if emp-status not = '00'
               display 'CLOSE MASTER FAILED ' emp-status
               move 12 to job-rc
           end-if
           move job-rc to return-code
           goback.
       load-employee.
           if seed-row(1:4) = spaces
               or (seed-row(5:2) not = 'IT' and not = 'HR')
               or seed-row(7:3) is not numeric
               or seed-row(7:3) = '000'
               display 'INVALID MASTER ROW ' seed-row(1:9)
               move 8 to job-rc
           else
               move seed-row(1:9) to emp-row
               write emp-row
               if emp-status not = '00'
                   display 'WRITE FAILED ' emp-id ' FS=' emp-status
                   move 12 to job-rc
               end-if
           end-if.
