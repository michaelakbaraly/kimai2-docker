docker run --rm --name kimai-mysql-testing \
    -e MYSQL_DATABASE=kimai \
    -e MYSQL_USER=kimai \
    -e MYSQL_PASSWORD=kimai \
    -e MYSQL_ROOT_PASSWORD=kimai \
    -p 3399:3306 -d mysql

docker run --rm --name kimai-test \
    -ti \
    -p 8001:8001 \
    -e DATABASE_URL=mysql://kimai:kimai@${HOSTNAME}:3306/kimai \
    kimai/kimai2:apache