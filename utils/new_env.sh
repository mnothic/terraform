check(){
  if [ -z "$1" ]; then
     echo Usage $0: origin dest region  
     exit 1
  fi
}
check $1
ORIG=$1
shift
check $1
DEST=$1
shift
check $1
REGION=$1

rsync -av --exclude=".*" $ORIG/ $DEST
sed -i -e "s/country = .*/country = \"$DEST\"/g" $DEST/terraform.tfvars
sed -i -e "s/region = .*/region = \"$REGION\"/g" $DEST/terraform.tfvars
