OUTPUT_FORMAT(binary)
SECTIONS
{
  . = 0x100;
  .text :
  {
    __start = .;
    *(.text)

   __end = .;
  }
}
