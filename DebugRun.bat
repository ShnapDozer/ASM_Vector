nasm -f win64 -g test.asm -o test.o
gcc -Wall -g  -c main.c -o main.o
gcc -o asm_test.exe main.o test.o
gdb -q asm_test 