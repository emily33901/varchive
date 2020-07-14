module archive

#include "@VROOT/archive_helper.h"

#include "@VROOT/libarchive/libarchive/archive.h"
#include "@VROOT/libarchive/libarchive/archive_entry.h"

#flag windows -L @VROOT/win64/
#flag -l archive
#flag -l zlib

fn C.archive_read_new() voidptr
fn C.archive_read_support_filter_all(a voidptr) int
fn C.archive_read_open_memory(a, data voidptr, size i64) int
fn C.archive_read_next_header(a voidptr) int
fn C.archive_read_data() int
fn C.archive_read_free() int
fn C.archive_read_support_format_zip() int
fn C.archive_errno() int

pub fn deflate(@in []byte, out_size int) ?[]byte {
	out := []byte{ len: out_size }

	archive := C.archive_read_new()
	defer { C.archive_read_free(archive) }

	mut result := C.archive_read_support_filter_all(archive)
	if result != C.ARCHIVE_OK {
		return error('Failed to set support filter')
	}

	result = C.archive_read_support_format_zip(archive)
	if result != C.ARCHIVE_OK {
		return error('Failed to set format')
	}

	result = C.archive_read_open_memory(archive, @in.data, i64(@in.len))
	if result != C.ARCHIVE_OK {
		code := C.archive_errno(archive)
		return error('Failed to open memory 0x$code:X')
	}

	entry := voidptr(0)
	result = C.archive_read_next_header(archive, &entry)
	if result != C.ARCHIVE_OK {
		return error('Failed to read header')
	}

	// TODO maybe check some of the other stuff

	C.archive_read_data(archive, out.data, out.len)
	return out
}