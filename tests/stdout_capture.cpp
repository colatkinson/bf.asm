#include <unistd.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdio.h>
#include <vector>

#ifndef O_TMPFILE
#define __O_TMPFILE 020000000
#define O_TMPFILE (__O_TMPFILE | O_DIRECTORY)
#define O_TMPFILE_MASK (__O_TMPFILE | O_DIRECTORY | O_CREAT)
#endif

extern "C" int bf_interp(const char *script);

// TODO(colin): Error checking on all syscalls
class scoped_stdout_capture {
  int out;
  int orig;

public:
  scoped_stdout_capture() {
    // Flush any remaining output
    // TODO(colin): Should this be right before the dup2?
    fflush(stdout);

    // Create a temp file
    out = open("/tmp/", O_TMPFILE | O_RDWR);

    // Keep a copy of actual stdout's fd
    orig = dup(STDOUT_FILENO);

    // Atomically replace stdout with our temp file
    dup2(out, STDOUT_FILENO);
  }

  ~scoped_stdout_capture() {
    // Flush any remaining content
    fflush(stdout);

    // Set stdout back to its original destination
    dup2(orig, STDOUT_FILENO);

    // We don't need these anymore
    close(orig);
    close(out);
  }

  void flush()
  {
    fflush(stdout);
  }

  std::vector<char> read()
  {
    fflush(stdout);

    // Acquire the size of the file by seeking to the end
    off_t fsize = lseek(out, 0, SEEK_END);

    // Seek back to the beginning
    lseek(out, 0, SEEK_SET);

    // Read into the vector
    std::vector<char> res(fsize, '\0');
    ::read(out, &res[0], fsize);

    return res;
  }
};


int main(int argc, char **argv)
{
  std::vector<char> out;
  {
    scoped_stdout_capture cap;
    printf("ggg\n");
    cap.flush();

    bf_interp("+[-[<<[+[--->]-[<<<]]]>>>-]>-.---.>..>.<<<<-.<+.>>>>>.>.<<.<-.");

    out = cap.read();

    printf("\n\nzzz\n");
    cap.flush();

    out = cap.read();
  }

  printf("%s", &out[0]);

    return 0;
}
