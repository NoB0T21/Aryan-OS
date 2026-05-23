#include "kernel.h"

volatile char* video = (volatile char*)0xB8000;

void clear_screen() {
    for (int i = 0; i < 80 * 25; i++) {
        video[i * 2] = ' ';
        video[i * 2 + 1] = 0x0F;
    }
}

void print(char* str) {
    int i = 0;

    while (str[i] != '\0') {
        video[i * 2] = str[i];
        video[i * 2 + 1] = 0x0F;
        i++;
    }
}

void kernel_main() {
    clear_screen();

    print("Welcome to AryanOS");

    while (1) {
    }
}