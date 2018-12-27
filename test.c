//
// Created by colin on 12/26/18.
//

extern int bf_interp(const char *script);

int main(int argc, char **argv)
{
    return bf_interp(",[.-[->+<]>+]");
}