#ifndef RUST_SDK_H
#define RUST_SDK_H

/* 该文件由 cbindgen 自动生成，请勿手动修改 */

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef void (*rust_FetchContactsCallback)(uint8_t *data, uintptr_t len);

typedef void (*rust_FetchMailsCallback)(uint8_t*, uintptr_t);

void rust_sdk_print_hello(void);

void rust_sdk_fetch_contacts_async(int32_t page,
                                   int32_t page_size,
                                   const char *file_path,
                                   rust_FetchContactsCallback callback);

void rust_sdk_fetch_mails_async(int32_t page,
                                int32_t page_size,
                                const char *file_path,
                                rust_FetchMailsCallback callback);

void rust_sdk_free_data(uint8_t *ptr);

#endif  /* RUST_SDK_H */
