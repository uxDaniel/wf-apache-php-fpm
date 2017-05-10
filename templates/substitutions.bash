STACKNAME="mystack"
ROOTDIR="$HOME/shared/php-7.1.4"
PORT="77777"
DOMAIN1="me.webfactional.com"
APPDIR1="$HOME/webapps/app1"

sed -i "s^PLACEHOLDER_STACKNAME^${STACKNAME}^g" *.template
sed -i "s^PLACEHOLDER_ROOTDIR^${ROOTDIR}^g" *.template
sed -i "s^PLACEHOLDER_HOME^${HOME}^g" *.template
sed -i "s^PLACEHOLDER_PORT^${PORT}^g" *.template
sed -i "s^PLACEHOLDER_DOMAIN1^${DOMAIN1}^g" *.template
sed -i "s^PLACEHOLDER_APPDIR1^${APPDIR1}^g" *.template
