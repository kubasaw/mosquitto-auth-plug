
CDBDIR=tinycdb-0.78
CDB=$(CDBDIR)/cdb

CDBLIB=$(CDBDIR)/libcdb.a
CDBINC=$(CDBDIR)/

MOSQUITTOSRC=../../../../pubgit/MQTT/mosquitto/src
OPENSSLDIR=/usr/local/stow/openssl-1.0.0c/

OSSLINC=-I$(OPENSSLDIR)/include
OSSLIBS=-L$(OPENSSLDIR)/lib -lcrypto -lmosquitto

CFLAGS=-fPIC -I$(MOSQUITTOSRC) -Wall -Werror $(OSSLINC) -I$(CDBINC) -DDEBUG

all: auth-plug.so np pwdb.cdb

auth-plug.so : auth-plug.c redis.o sqlite.o base64.o pbkdf2-check.o $(CDBLIB)
	$(CC) ${CFLAGS} -fPIC -shared $^ -o $@  $(OSSLIBS) -L$(CDBDIR) -lcdb -lhiredis -lsqlite3

redis.o: redis.c redis.h Makefile
sqlite.o: sqlite.c sqlite.h Makefile
base64.o: base64.c base64.h Makefile
pbkdf2-check.o: pbkdf2-check.c base64.h Makefile

np: np.c base64.o
	$(CC) $(CFLAGS) $^ -o $@ $(OSSLIBS)

$(CDBLIB):
	(cd $(CDBDIR); make libcdb.a cdb )

pwdb.cdb: pwdb.in
	$(CDB) -c -m  pwdb.cdb pwdb.in
clean :
	rm -f *.o *.so 
	(cd $(CDBDIR); make realclean )