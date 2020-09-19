# Address Reader

A component that reads customer addresses from a given sql database

Note: It doesn't actually do that. It's a dummy component that is given a set of dynamic database credentails by vault. It exists for the purposes of demonstrating that this has happened. 

The Dockerfile is based on a psql client. The init file configures vault and initialises dynamic secrets. The Makefile can deploy postgres, build the address-reader and run the initialisation.
