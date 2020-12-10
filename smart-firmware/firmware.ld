ENTRY(_start)

SECTIONS {
    . = 0x80000000;

    .text : {
        *(.text .text.*)
    }
    
    .rodata : {
        *(.rodata .rodata.*)
    }
    
    .data : {
        *(.data .data.*)
    }
    
    .bss : {
        *(.bss .bss.*)
    }
    
    PROVIDE(__bss_end = .);
    ASSERT(__bss_end < 0x80100000, "Error: kernel too large (should fit in 1024 KiB)")
    
    /DISCARD/ : {
        *(.note.GNU-stack .comment)
    }
}
