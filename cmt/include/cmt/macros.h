#define mtIdPropertyDef(fName, objT, propertyT, propertyN) \
MT_EXPORT Mt ## propertyT fName(Mt ## objT *obj);

#define mtIdPropertyImpl(fName, objT, propertyT, propertyN) \
MT_EXPORT Mt ## propertyT fName(Mt ## objT *obj) { return [(id<MTL ## objT>)obj propertyN]; } 
