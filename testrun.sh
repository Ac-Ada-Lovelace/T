make clean
make build
rm ./test.asm
./tcc < test.c > test.asm
