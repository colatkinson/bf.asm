OUTPUT_FORMAT(binary)
SECTIONS
{
  . = 0x100;
  .text :
  {
    __start = .;
    *(.text)

   . = ALIGN(512);
   __end = .;
  }
}
