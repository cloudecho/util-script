# pt-stat-parallel.awk
# author yong.ma
# version 3.0
{ 
  time = $1;
  k = $category_column;
  latency = $latency_column;
  if (debug && t_count["-"]==1) { 
    print "\n", $0;
    print "NR:", NR, "time:", time, "code:", $status_column, "latency:", latency;
  }
  if (time < time_a || time > time_b) { next; }

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
}

END {
  for(k in t_count)    { printf("t_count\t%s\t%d\n",     k, t_count[k]); }
  for(k in countdict)  { printf("countdict\t%s\t%d\n",   k, countdict[k]); }
  for(k in sum_latency){ printf("sum_latency\t%s\t%d\n", k, sum_latency[k]); }
  for(k in latencydict){ printf("latencydict\t%s\t%d\n", k, latencydict[k]); }
  for(k in satisfied_count) { printf("satisfied_count\t%s\t%d\n",  k, satisfied_count[k]); }
  for(k in tolerating_count){ printf("tolerating_count\t%s\t%d\n", k, tolerating_count[k]); }
} 