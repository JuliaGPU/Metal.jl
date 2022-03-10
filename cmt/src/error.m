#include "impl/common.h"
#include "cmt/common.h"

MT_EXPORT
void
mtErrorRelease(NsError *err) {
    [(NSError *)err release];
}

MT_EXPORT
NsInteger
mtErrorCode(NsError *err) { return [(NSError *)err code]; }

MT_EXPORT
const char*
mtErrorDomain(NsError *err) {
    return Cstring([(NSError *)err domain]);
}

MT_EXPORT
const char*
mtErrorUserInfo(NsError *err) {
    return CstringFromDict([(NSError*)err userInfo]);
}

MT_EXPORT
const char*
mtErrorLocalizedDescription(NsError *err) {
    return Cstring([(NSError*)err localizedDescription]);
}

MT_EXPORT
void
mtErrorLocalizedRecoveryOptions(NsError *err, size_t* count, const char** options) {
    NSArray<NSString *> *_strings = [(NSError*)err localizedRecoveryOptions];
    int n = [_strings count];

    if (*count == 0) {
        *count = n;
    } else {
        assert(*count <= n);
        for (int i=0; i < *count; i++)
            options[i] = Cstring([_strings objectAtIndex:i]);
    }

    return;
}

MT_EXPORT
const char*
mtErrorLocalizedRecoverySuggestion(NsError *err) {
    return Cstring([(NSError*)err localizedRecoverySuggestion]);
}

MT_EXPORT
const char*
mtErrorLocalizedFailureReason(NsError *err) {
    return Cstring([(NSError*)err localizedFailureReason]);
}



