## util-script
Some util scripts.

- jmeter scripts
  - start-pt 
  - pt-stat

## Usage
### start-pt
```
$ ./jmeter-scripts/start-pt
usage:  start-pt [-d] [-T toleration_threshold] [-F frustration_threshold] 
                 testcase [jmeter_options]
  e.g.  start-pt test1.jmx
        start-pt test1.jmx -o output/test1 -e
        start-pt -T 500 -F 1000 test1.jmx -o output/test1 -e

  -T    the toleration threshold in milliseconds, default 500
  -F    the frustration threshold in milliseconds, default 1500
  -d    debug mode
```

### pt-stat
```
$ ./jmeter-scripts/pt-stat 
usage:  pt-stat [-d] [-c category_column] [-e elapsed_column] [-l latency_column]
                [-s status_column] [-o ok_codes] [-x strip_milliseconds]
                [-T toleration_threshold] [-F frustration_threshold]
                [-P parallel_number] [-L 1000*lines_per_smaller_jtl_file]
                jtl_file
  e.g.  pt-stat test.jtl
        pt-stat -x1000 test.jtl
        pt-stat -x1000 -e14 -T10 -F20 test.jtl
        pt-stat -x1000 -o200,201 test.jtl
        pt-stat -x1000 -otrue -s8 test.jtl
        pt-stat -x1000 -P2 -L1 test.jtl

  -c    the index of category column, default 3
  -e    the index of elapsed column, default 2
  -l    the index of latency column, default 14
  -s    the index of status column, default 4
  -o    the list of OK status code, comma-separated, default 200
  -x    ingore the head and tail records of jtl_file by strip_milliseconds, default 60000
  -T    the toleration threshold in milliseconds, default 500
  -F    the frustration threshold in milliseconds, default 1500
  -P    the parallel number of analysing, default is the cpu cores
  -L    1000*L lines in per smaller jtl files, default 5000
  -d    debug mode
```
