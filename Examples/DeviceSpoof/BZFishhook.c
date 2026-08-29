// Copyright (c) 2013, Facebook, Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 1. Redistributions of source code must retain this copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce this copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. Neither the name Facebook nor the names of its contributors may be used
//    to endorse or promote products derived from this software without prior
//    written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DAMAGES ARISING FROM USE.

#include "BZFishhook.h"

#include <mach/mach.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

#ifndef SEG_DATA_CONST
#define SEG_DATA_CONST "__DATA_CONST"
#endif
#ifndef SEG_AUTH
#define SEG_AUTH "__AUTH"
#endif
#ifndef SEG_AUTH_CONST
#define SEG_AUTH_CONST "__AUTH_CONST"
#endif

typedef struct mach_header_64 bz_mach_header_t;
typedef struct segment_command_64 bz_segment_command_t;
typedef struct section_64 bz_section_t;
typedef struct nlist_64 bz_nlist_t;

static bool bz_is_pointer_section(const bz_section_t *section) {
    uint32_t type = section->flags & SECTION_TYPE;
    return type == S_LAZY_SYMBOL_POINTERS || type == S_NON_LAZY_SYMBOL_POINTERS;
}

static bool bz_is_data_segment(const char *name) {
    return strcmp(name, SEG_DATA) == 0 ||
           strcmp(name, SEG_DATA_CONST) == 0 ||
           strcmp(name, SEG_AUTH) == 0 ||
           strcmp(name, SEG_AUTH_CONST) == 0;
}

static void bz_rebind_section(const bz_section_t *section,
                              intptr_t slide,
                              bz_nlist_t *symbolTable,
                              char *stringTable,
                              uint32_t *indirectSymbolTable,
                              struct bz_rebinding rebindings[],
                              size_t rebindingsCount) {
    uint32_t *indices = indirectSymbolTable + section->reserved1;
    void **bindings = (void **)((uintptr_t)slide + section->addr);
    size_t bindingCount = section->size / sizeof(void *);
    bool madeWritable = false;

    for (size_t i = 0; i < bindingCount; i++) {
        uint32_t symbolIndex = indices[i];
        if (symbolIndex == INDIRECT_SYMBOL_ABS ||
            symbolIndex == INDIRECT_SYMBOL_LOCAL ||
            symbolIndex == (INDIRECT_SYMBOL_LOCAL | INDIRECT_SYMBOL_ABS)) {
            continue;
        }

        char *symbolName = stringTable + symbolTable[symbolIndex].n_un.n_strx;
        if (symbolName[0] != '_' || symbolName[1] == '\0') continue;

        for (size_t j = 0; j < rebindingsCount; j++) {
            if (strcmp(symbolName + 1, rebindings[j].name) != 0) continue;

            if (!madeWritable) {
                kern_return_t result = vm_protect(mach_task_self(),
                                                  (vm_address_t)bindings,
                                                  (vm_size_t)section->size,
                                                  false,
                                                  VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
                if (result != KERN_SUCCESS) return;
                madeWritable = true;
            }

            if (rebindings[j].replaced && bindings[i] != rebindings[j].replacement) {
                *rebindings[j].replaced = bindings[i];
            }
            bindings[i] = rebindings[j].replacement;
            break;
        }
    }
}

int bz_rebind_symbols_image(void *imageHeader,
                            intptr_t slide,
                            struct bz_rebinding rebindings[],
                            size_t rebindingsCount) {
    if (!imageHeader || !rebindings || rebindingsCount == 0) return -1;

    const bz_mach_header_t *header = (const bz_mach_header_t *)imageHeader;
    if (header->magic != MH_MAGIC_64) return -1;

    const bz_segment_command_t *linkedit = NULL;
    const struct symtab_command *symtabCommand = NULL;
    const struct dysymtab_command *dysymtabCommand = NULL;
    uintptr_t cursor = (uintptr_t)header + sizeof(*header);

    for (uint32_t i = 0; i < header->ncmds; i++) {
        const struct load_command *loadCommand = (const struct load_command *)cursor;
        if (loadCommand->cmd == LC_SEGMENT_64) {
            const bz_segment_command_t *segment = (const bz_segment_command_t *)cursor;
            if (strcmp(segment->segname, SEG_LINKEDIT) == 0) linkedit = segment;
        } else if (loadCommand->cmd == LC_SYMTAB) {
            symtabCommand = (const struct symtab_command *)cursor;
        } else if (loadCommand->cmd == LC_DYSYMTAB) {
            dysymtabCommand = (const struct dysymtab_command *)cursor;
        }
        cursor += loadCommand->cmdsize;
    }

    if (!linkedit || !symtabCommand || !dysymtabCommand || dysymtabCommand->nindirectsyms == 0) {
        return -1;
    }

    uintptr_t linkeditBase = (uintptr_t)slide + linkedit->vmaddr - linkedit->fileoff;
    bz_nlist_t *symbolTable = (bz_nlist_t *)(linkeditBase + symtabCommand->symoff);
    char *stringTable = (char *)(linkeditBase + symtabCommand->stroff);
    uint32_t *indirectSymbolTable = (uint32_t *)(linkeditBase + dysymtabCommand->indirectsymoff);

    cursor = (uintptr_t)header + sizeof(*header);
    for (uint32_t i = 0; i < header->ncmds; i++) {
        const struct load_command *loadCommand = (const struct load_command *)cursor;
        if (loadCommand->cmd == LC_SEGMENT_64) {
            const bz_segment_command_t *segment = (const bz_segment_command_t *)cursor;
            if (bz_is_data_segment(segment->segname)) {
                const bz_section_t *sections = (const bz_section_t *)(segment + 1);
                for (uint32_t j = 0; j < segment->nsects; j++) {
                    if (bz_is_pointer_section(&sections[j])) {
                        bz_rebind_section(&sections[j], slide, symbolTable, stringTable,
                                          indirectSymbolTable, rebindings, rebindingsCount);
                    }
                }
            }
        }
        cursor += loadCommand->cmdsize;
    }
    return 0;
}
