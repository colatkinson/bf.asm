//
// Created by colin on 12/26/18.
//

#include <stdio.h>
#include <stdlib.h>

extern int bf_interp(const char *script);

int main(int argc, char **argv)
{
    if (argc > 1) {
        // TODO(colin): Error handling
        FILE *f = fopen(argv[1], "r");
        fseek(f, 0, SEEK_END);
        long off = ftell(f);
        fseek(f, 0, SEEK_SET);

        char *buf = (char *)calloc(off + 1, sizeof(char));
        fread(buf, sizeof(char), off, f);

        int ret = bf_interp(buf);
        free(buf);

        return ret;
    }

    bf_interp(",[.-[->+<]>+]");

    printf("\n\n");

    bf_interp("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++."
              "+++++++++++++++++++++++++++++."
              "+++++++."
              "."
              "+++."
              "-------------------------------------------------------------------."
              "------------."
              "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++."
              "--------."
              "+++."
              "------."
              "--------."
              "-------------------------------------------------------------------.");

    printf("\nYeehaw\n");

    bf_interp("+[>+[>+[+]<+]<+]");

    //bf_interp("+[>+[+]<+]");

    return bf_interp(",[.-[->+<]>+]");
    // return 0;
}
