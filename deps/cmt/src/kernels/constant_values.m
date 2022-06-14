/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

/* https://developer.apple.com/documentation/metal/mtlfunctionconstantvalues?language=objc */

#include "cmt/kernels/constant_values.h"
#include "impl/common.h"

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionConstantValuesSetWithIndex(MtFunctionConstantValues *funval, const void *value, MtDataType typ, NsUInteger idx) {
	[(MTLFunctionConstantValues*)funval setConstantValue: value
											       type: (MTLDataType)typ
											    atIndex: idx];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionConstantValuesSetWithName(MtFunctionConstantValues *funval, const void *value, MtDataType typ, const char* name) {
	[(MTLFunctionConstantValues*)funval setConstantValue: value
											       type: (MTLDataType)typ
											    withName: mtNSString(name)];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionConstantValuesSetWithRange(MtFunctionConstantValues *funval, const void *value, MtDataType typ, NsRange range) {
	[(MTLFunctionConstantValues*)funval setConstantValues: value
											         type: (MTLDataType)typ
											    withRange: mtNSRange(range)];
}

MT_EXPORT
MT_API_AVAILABLE(mt_macos(10.12), mt_ios(10.0))
void
mtFunctionConstantValuesReset(MtFunctionConstantValues *funval){
	[(MTLFunctionConstantValues*)funval reset];
}
