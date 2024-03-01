#include "pear.h"

int
main (int argc, char *argv[]) {
  pear_key_t key = KEY;
  const char *name = NAME;

  return pear_launch(argc, argv, key, name);
}
