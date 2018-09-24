Normalize sparse matrix into a question/answer variable/value table

github
https://tinyurl.com/y8p8pu92
https://github.com/rogerjdeangelis/utl-normalize-sparse-matrix-into-a-question-answer-table

Stackoverflow
https://tinyurl.com/yaeoyo8q
https://stackoverflow.com/questions/52469680/removing-missing-data-in-data-step-with-do-loop

Our own Q (Quentin)
https://stackoverflow.com/users/3369544/quentin

This is a good question.

%let pgm=utl_skip_over_missing_values_to+populate_treatments;

 Three Solutions

     1. Proc transpose
     2. Input is a dataset (coalesce)
     3. Input is a file ( Be nice if SAS could allow 'file input functionality' to parse strings)


INPUT  (two forms of input)
=====

CARDS
-----
  cards4;
  1 47.2 . 49.4
  2 . 56.6 53.6
  ;;;;

DATASET
-------                           PROC TRANSPOSE
                                     RULES
                               |     -----
 WORK.HAVE total obs=2         |    POSITION
                               |      Of
  BLK     T1      T2      T3   | BLK  TRT     Val
                               |
   1     47.2      .     49.4  |  1    1     47.2
                               |  1    3     49.5

   2       .     56.6    53.6  |  2    2     56.6
                               |  2    3     53.6

EXAMPLE OUTPUTS
---------------

1. Proc transpose

 WORK.HAVXPO total obs=4

 BLK    _NAME_    COL1

  1       T1      47.2
  1       T3      49.4
  2       T2      56.6
  2       T3      53.6

2. Input is a dataset (coalesce)

 My solution I like to complcate things
 WORK.WANT total obs=4

 BLK    TRT      Y

  1      1     47.2
  1      3     49.4
  2      2     56.6
  2      3     53.6

3. Input is a file (Our own Q)

 WORK.WANT total obs=4

 BLK    TRT      Y

  1      1     47.2
  1      3     49.4
  2      2     56.6
  2      3     53.6


PROCESS
=======

 1. Proc transpose Think Normalization - var/val question/answer

    proc transpose data=have out=havxpo(where=(col1 ne .));
      by blk;
    run;quit;

 2. Input is a dataset (coalesce)

    data want;

     retain obs blk trt y;
     keep   obs blk trt y;

     set have;
     obs+1;

     array forward[3]  t1-t3;
     array backward[3] t3-t1;

     y=coalesce(of forward[*]);
     trt=whichn(y,of forward[*]);
     output;

     obs+1;
     y=coalesce(of backward[*]);
     trt=4-whichn(y,of backward[*]);
     output;

    run;quit;

  3. Input is a file

     data want;
      input blk @;
      do trt=1,2,3;
       input y @;
       if y=. then continue;
       else output;
      end;
     cards4;
     1 47.2 . 49.4
     2 . 56.6 53.6
     ;;;;
     run;quit;

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
  input blk t1-t3;
cards4;
1 47.2 . 49.4
2 . 56.6 53.6
;;;;
run;quit;



