/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "cmt/types.h"

MT_HIDE
MT_INLINE
NSString*
mtNSString(const char *str) {
  return [NSString stringWithCString: str
                            encoding: NSUTF8StringEncoding];
}

MT_HIDE
MT_INLINE
const char*
Cstring(NSString* str) {
  return [str cStringUsingEncoding:NSUTF8StringEncoding];
}

MT_HIDE
MT_INLINE
MTLSize
mtMTLSize(MtSize size) {
	return MTLSizeMake(size.width, size.height, size.depth);
}

MT_HIDE
MT_INLINE
MtSize
mtSize(MTLSize size) {
	MtSize sz = {size.width, size.height, size.depth};
	return sz;
}

MT_HIDE
MT_INLINE
MTLOrigin
mtMTLOrigin(MtOrigin orig) {
	return MTLOriginMake(orig.x, orig.y, orig.z);
}

MT_HIDE
MT_INLINE
MtOrigin
mtOrigin(MTLOrigin orig) {
	MtOrigin o = {orig.x, orig.y, orig.z};
	return o;
}

MT_HIDE
MT_INLINE
MTLSizeAndAlign
mtMTLSizeAndAlign(MtSizeAndAlign s) {
	MTLSizeAndAlign o = {s.size, s.align};
	return o;
}

MT_HIDE
MT_INLINE
MtSizeAndAlign
mtSizeAndAlign(MTLSizeAndAlign s) {
	MtSizeAndAlign o = {s.size, s.align};
	return o;
}


MT_HIDE
MT_INLINE
NSRange
mtNSRange(NsRange range) {
	return NSMakeRange(range.location, range.length);
}

MT_HIDE
MT_INLINE
NsRange
mtRange(NSRange range) {
	NsRange r = {range.location, range.length};
	return r;
}

MT_HIDE
MT_INLINE
const char*
CstringFromDict(NSDictionary<NSErrorUserInfoKey, id> *dict) {
	return Cstring([NSString stringWithFormat:@"Dictionary: %@", dict]);
}

MT_HIDE
MT_INLINE
MTLRegion
mtMTLRegion(MtRegion region) {
	MTLRegion reg = {mtMTLOrigin(region.origin), mtMTLSize(region.size)};
	return reg;
}

MT_HIDE
MT_INLINE
MtRegion
mtRegion(MtRegion region) {
	MtRegion reg = {region.origin, region.size};
	return reg;
}

MT_HIDE
MT_INLINE
MtIndirectCommandBufferExecutionRange
mtIndirectCommandBufferExecutionRange(MTLIndirectCommandBufferExecutionRange range) {
	MtIndirectCommandBufferExecutionRange icbRange = {range.location, range.length};
    return icbRange;
}

MT_HIDE
MT_INLINE
MTLIndirectCommandBufferExecutionRange
mtMTLIndirectCommandBufferExecutionRange(MtIndirectCommandBufferExecutionRange range) {
	MTLIndirectCommandBufferExecutionRange icbRange = {range.location, range.length};
    return icbRange;
}


