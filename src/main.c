struct state {
    unsigned char stuff[32];
};

int main(void) {
    struct state foo = {};
}

void _exit(int a) { }
void _sbrk(void) { }
void _close_r(void) { }
void _lseek_r(void) { }
void _read_r(void) { }
void _write_r(void) { }
/* [] END OF FILE */
