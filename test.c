//
// Created by colin on 12/26/18.
//

#include <stdio.h>

extern int bf_interp(const char *script);

int main(int argc, char **argv)
{
    bf_interp(",[.-[->+<]>+]");

    printf("\nYeehaw\n");

    return bf_interp(",[.-[->+<]>+]");
}
