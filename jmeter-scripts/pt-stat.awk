# pt-stat.awk
# author yong.ma
# version 1.0
BEGIN {
  FS = ",";
  max_catlen = 0;
  countkeys[0] = "-";
  
  if(debug){ printf("counts: %s\n", counts) } 
  split(counts, arr, ",");
  for(i in arr){
    if(arr[i]){
      split(arr[i], kv, "=");
      if(debug) {printf("arr[i]: %s  kv: %s=%s\n", arr[i], kv[1], kv[2]);}
      countdict[kv[1]] = kv[2];
      if(max_catlen < length(kv[1])) {max_catlen = length(kv[1]);} 
    }
  }

  for(k in countdict) { 
    if (debug) { printf("countdict[%s]=%d\n", k, countdict[k]) };
    if(k != "-") {countkeys[length(countkeys)] = k;}
    count[k] = 0;
    min_latency[k] = -1;
    max_latency[k] = -1;
    sum_latency[k] = 0;
    latency_90[k] = -1;
    latency_95[k] = -1;
    latency_99[k] = -1;
    count_90[k] = countdict[k]*0.90;
    count_95[k] = countdict[k]*0.95;
    count_99[k] = countdict[k]*0.99;
  }
}

{ 
  time = $1;
  k = $category_column;
  latency = $latency_column;
  if (debug && count["-"]<1) { 
    print "\n"$0;
    print "NR:"NR, "time:"time, "code:"$status_column, "latency:"latency;
    print "count_90:"count_90[k], "count_95:"count_95[k], "count_99:"count_99[k];
  }
  if (NR == 1 || time < time_a || time > time_b) { next; }

  t_count["-"]++;
  t_count[k]++;
  if(0 == index(ok_codes,$status_column)){ next;}

  elapsed = $elapsed_column;
  count["-"]++;
  count[k]++;
  sum_latency["-"] += latency;
  sum_latency[k] += latency;

  if (elapsed <= Tthreshold) { 
    satisfied_count["-"]++; 
    satisfied_count[k]++; 
  } else if (elapsed <= Fthreshold) { 
    tolerating_count["-"]++;
    tolerating_count[k]++;
  }

  if (min_latency["-"] < 0){
    min_latency["-"] = latency;
    max_latency["-"] = latency;
  } else {
    if (latency < min_latency["-"]) { min_latency["-"] = latency; }
    if (latency > max_latency["-"]) { max_latency["-"] = latency; }
  }

  if (min_latency[k] < 0){
    min_latency[k] = latency;
    max_latency[k] = latency;
  } else {
    if (latency < min_latency[k]) { min_latency[k] = latency; }
    if (latency > max_latency[k]) { max_latency[k] = latency; }
  }

  if (latency_90["-"] < 0 && count["-"] >= count_90["-"]) {latency_90["-"] = latency;}
  if (latency_95["-"] < 0 && count["-"] >= count_95["-"]) {latency_95["-"] = latency;}
  if (latency_99["-"] < 0 && count["-"] >= count_99["-"]) {latency_99["-"] = latency;}

  if (latency_90[k] < 0 && count[k] >= count_90[k]) {latency_90[k] = latency;}
  if (latency_95[k] < 0 && count[k] >= count_95[k]) {latency_95[k] = latency;}
  if (latency_99[k] < 0 && count[k] >= count_99[k]) {latency_99[k] = latency;}
}

END {
  printf("\nreporting ...\n%"(max_catlen+4)"s %8s %8s %8s %s %s %s %s %s %s\n",
  "LABEL", "APDEX", "OK%", "TPS", "AVG_LATENCY", "LATENCY90%", "LATENCY95%", "LATENCY99%", "MIN_LATENCY", "MAX_LATENCY");  
  for (i=0; i<length(countkeys); i++) {
    k = countkeys[i];
    tps = 1000*count[k]/(time_b - time_a);
    if(count[k]) {avg_latency = sum_latency[k]/count[k];}
    ok_rate = 100*count[k]/t_count[k];
    apdex = (satisfied_count[k] + tolerating_count[k]/2)/t_count[k]; 

    printf("[ %"max_catlen"s ] %8.3f %8.3f %8d %11d %10d %10d %10d %11d %11d\n",
    k, apdex, ok_rate, tps, avg_latency, latency_90[k], latency_95[k], latency_99[k], min_latency[k], max_latency[k]);
  }
  printf("\n")
} 
