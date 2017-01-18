export AWS_REGION=us-west-1
terraforming r53z > route53_zones.tf
terraforming r53r > route53_records.tf

cat zones.txt|while read line; do NAME=$(echo $line |cut -d" " -f1); ZONE=$(echo $line |cut -d" " -f2); grep \"${NAME::-1}\" route53_zones.tf -B1 -A6 > ${NAME}tf; echo "--" >> ${NAME}tf; done

cat zones.txt|while read line; do NAME=$(echo $line |cut -d" " -f1); ZONE=$(echo $line |cut -d" " -f2); grep $ZONE route53_records.tf -B1 -A6 >> ${NAME}tf; done

rm route53_zones.tf route53_records.tf
