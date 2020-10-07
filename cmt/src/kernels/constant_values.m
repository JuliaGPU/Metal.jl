//https://developer.apple.com/documentation/metal/mtlfunctionconstantvalues?language=objc

#include "cmt/kernels/constant_values.h"
#include "impl/common.h"

MT_EXPORT
void
mtFunctionConstantValuesSetWithIndex(MtFunctionConstantValues *funval, const void *value, MtDataType typ, NsUInteger idx) {
	[(MTLFunctionConstantValues*)funval setConstantValue: value
											       type: (MTLDataType)typ
											    atIndex: idx];
}

MT_EXPORT
void
mtFunctionConstantValuesSetWithName(MtFunctionConstantValues *funval, const void *value, MtDataType typ, const char* name) {
	[(MTLFunctionConstantValues*)funval setConstantValue: value
											       type: (MTLDataType)typ
											    withName: mtNSString(name)];
}

MT_EXPORT
void
mtFunctionConstantValuesSetWithRange(MtFunctionConstantValues *funval, const void *value, MtDataType typ, NsRange range) {
	[(MTLFunctionConstantValues*)funval setConstantValues: value
											         type: (MTLDataType)typ
											    withRange: mtNSRange(range)];
}

MT_EXPORT
void
mtFunctionConstantValuesReset(MtFunctionConstantValues *funval){
	[(MTLFunctionConstantValues*)funval reset];
}

