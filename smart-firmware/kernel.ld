ENTRY(__bootloader_start)

SECTIONS {
    . = 0x80100000;

    .boot : {
        /* ensure that the bootloader is at the beginning */
        KEEP (*(.text.boot))
    }

    .text : {
        *(.text .text.*)
    }
    
    .rodata : {
        *(.rodata .rodata.*)
    }
    
    .preinit_array : {
        PROVIDE_HIDDEN(__preinit_array_start = .);
        KEEP (*(SORT(.preinit_array.*)))
        KEEP (*(.preinit_array*))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    }
    
    .init_array : {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array*))
        PROVIDE_HIDDEN (__init_array_end = .);
    }
    
    .fini_array : {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(SORT(.fini_array.*)))
        KEEP (*(.fini_array*))
        PROVIDE_HIDDEN (__fini_array_end = .);
    }
    
    .tdata : {
        *(.tdata)
    }
    . = ALIGN(0x10);
    PROVIDE(__tbss_start = .);
    .tbss : {
        *(.tbss)
    }
    . = ALIGN(0x10);
    PROVIDE(__tbss_end = .);
    
    .data : {
        *(.data .data.*)
    }
    
    . = ALIGN(0x10);
    PROVIDE(__bss_start = .);
    
    .bss : {
        *(.bss .bss.*)
    }
    
    . = ALIGN(0x10);
    PROVIDE(__bss_end = .);
    PROVIDE(ebss = .);
    
    /DISCARD/ : {
        *(.note.GNU-stack .comment)
    }
}
