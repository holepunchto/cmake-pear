#include <pear.h>

int
main(int argc, char *argv[]) {
  pear_id_t id = ID;
  const char *name = NAME;
  const char *link = LINK;

  return pear_launch(argc, argv, id, name, link);
}
