# pt-stat.awk
# author yong.ma
# version 2.1
function get_epoch(){
  cmd = "date +%s";
  cmd | getline d;
  close(cmd);
  return d;
}

BEGIN {
  duration = time_b - time_a;
  p0 = 0;
  start_time = get_epoch();
  if(debug) {print "start_time:", start_time}
  printf("DONE: %14s","");
}

{ 
  time = $1;
  k = $category_column;
  latency = $latency_column;
  if (debug && t_count["-"]==1) { 
    print "\n", $0;
    print "NR:", NR, "time:", time, "code:", $status_column, "latency:", latency;
  }
  if (NR == 1 || time < time_a || time > time_b) { next; }

  t_count["-"]++;
  t_count[k]++;
  if(0 == index(ok_codes,$status_column)){ next;}
   
  elapsed = $elapsed_column;
  if (elapsed <= Tthreshold) { 
    satisfied_count["-"]++; 
    satisfied_count[k]++; 
  } else if (elapsed <= Fthreshold) { 
    tolerating_count["-"]++;
    tolerating_count[k]++;
  }

  countdict["-"]++;
  countdict[k]++;
  sum_latency["-"] += latency;
  sum_latency[k] += latency;
  latencydict["-",latency]++;
  latencydict[k,latency]++;

  p=100.0*(time - time_a)/duration;
  if (p - p0 >= 1) {
    p0 = p; t = get_epoch(); 
    time_left = (100-p)*(t-start_time)/p;
    printf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b%3d%% %5ds ET", p, time_left);
    if(debug){printf(" t:%d t-start_time:%d\n", t, t-start_time);}
    fflush();
  }
}

END {
  printf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b%3d%% %5ds ET", 100, 0);

  if(length(countdict)==0){
    print "No success records."
    exit;
  }

  max_catlen = 0;
  countkeys[0] = "-";

  if(debug) {print "";}
  for(k in countdict) { 
    if (debug) { printf("countdict[%s]=%d\n", k, countdict[k]) };
    if(k != "-") {countkeys[length(countkeys)] = k;}
    if(max_catlen < length(k)) {max_catlen = length(k);} 
    min_latency[k] = -1;
    max_latency[k] = -1;
    latency_90[k] = -1;
    latency_95[k] = -1;
    latency_99[k] = -1;
    count_90[k] = countdict[k]*0.90;
    count_95[k] = countdict[k]*0.95;
    count_99[k] = countdict[k]*0.99;
  }

  if(debug) {print "";}
  for (key in latencydict) {
    split(key, arr, SUBSEP);
    k = arr[1]; latency = arr[2]+0;
    if (debug && min_latency[k] < 0) {
      printf("%s:%d [category:%s, latency:%d, count:%d]\n",
      key, latencydict[key], k, latency, latencydict[key]);
    }

    if (min_latency[k] < 0) {
      min_latency[k] = latency;
      max_latency[k] = latency;
    } else {
      if (latency < min_latency[k]) { min_latency[k] = latency; }
      if (latency > max_latency[k]) { max_latency[k] = latency; }
    }
  }

  printf("\nreporting ...\n%"(max_catlen+4)"s %8s %8s\n", "LABEL", "OK_COUNT", "OK_COUNT%");
  for (i=0; i<length(countkeys); i++) {
    k = countkeys[i];
    count_rate = 100.0*countdict[k]/countdict["-"];
    printf("[ %"max_catlen"s ] %8d %8.3f\n", k, countdict[k], count_rate);

    for(latency=min_latency[k]; latency<=max_latency[k]; latency++){
      if ((k, latency) in latencydict){
        count[k] += latencydict[k, latency];
        if (latency_90[k] < 0 && count[k] >= count_90[k]) {latency_90[k] = latency;}
        if (latency_95[k] < 0 && count[k] >= count_95[k]) {latency_95[k] = latency;}
        if (latency_99[k] < 0 && count[k] >= count_99[k]) {latency_99[k] = latency;}
      }
    }
  }

  printf("\n%"(max_catlen+4)"s %8s %8s %8s %s %s %s %s %s %s\n",
  "LABEL", "APDEX", "OK%", "TPS", "AVG_LATENCY", "LATENCY90%", "LATENCY95%", "LATENCY99%", "MIN_LATENCY", "MAX_LATENCY");  
  for (i=0; i<length(countkeys); i++) {
    k = countkeys[i];
    tps = 1000*countdict[k]/(time_b - time_a);
    if(countdict[k]) {avg_latency = sum_latency[k]/countdict[k];}
    ok_rate = 100.0*countdict[k]/t_count[k];
    apdex = (satisfied_count[k] + tolerating_count[k]/2)/t_count[k]; 

    printf("[ %"max_catlen"s ] %8.3f %8.3f %8d %11d %10d %10d %10d %11d %11d\n",
    k, apdex, ok_rate, tps, avg_latency, latency_90[k], latency_95[k], latency_99[k], min_latency[k], max_latency[k]);
  }
  printf("\n")
} 
