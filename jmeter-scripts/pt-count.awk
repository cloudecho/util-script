# pt-count.awk
# author yong.ma
# version 1.0
{
  time = $1;
  if (NR == 1 || time < time_a || time > time_b || 0 == index(ok_codes,$status_column)) { next; }

  counts["-"]++;
  counts[$category_column]++;
} 

END { 
  for (k in counts) {
    if(k) { printf("%s=%d,", k, counts[k]); }
  }
}