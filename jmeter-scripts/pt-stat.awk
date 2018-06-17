# pt-stat.awk
# author yong.ma
# version 3.0
BEGIN { 
  FS = "\t"
}

{ 
  if (debug) {print "pt-stat.awk: ", $0}
  if ($1 == "t_count") { t_count[$2] += $3; }
  else if ($1 == "countdict") { countdict[$2] += $3; }
  else if ($1 == "sum_latency") { sum_latency[$2] += $3; }
  else if ($1 == "latencydict") { latencydict[$2] += $3; }
  else if ($1 == "satisfied_count") { satisfied_count[$2] += $3; }
  else if ($1 == "tolerating_count") { tolerating_count[$2] += $3; }
}

END {
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
