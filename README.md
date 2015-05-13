# Platformiented

Run this using git@github.com:orientechnologies/orientdb-docker.git

My run command: `docker run --name orientdb -v $(pwd)/config:/opt/orientdb/config -p 2424:2424 -p 2480:2480 orientdb` from inside the
orientdb-docker directory (after setting up the config and database directories).

./test.rb is really the only functioning file here.

