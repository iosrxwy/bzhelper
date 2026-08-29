// Based on fishhook by Facebook, Inc. (BSD 3-Clause License).
// This sample only needs the image-scoped API, so system images are not patched.

#ifndef BZFishhook_h
#define BZFishhook_h

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct bz_rebinding {
    const char *name;
    void *replacement;
    void **replaced;
};

int bz_rebind_symbols_image(void *header,
                            intptr_t slide,
                            struct bz_rebinding rebindings[],
                            size_t rebindingsCount);

#ifdef __cplusplus
}
#endif

#endif
