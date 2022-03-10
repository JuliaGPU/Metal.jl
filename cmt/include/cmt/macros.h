/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#define mtIdPropertyDef(fName, objT, propertyT, propertyN) \
MT_EXPORT Mt ## propertyT fName(Mt ## objT *obj);

#define mtIdPropertyImpl(fName, objT, propertyT, propertyN) \
MT_EXPORT Mt ## propertyT fName(Mt ## objT *obj) { return [(id<MTL ## objT>)obj propertyN]; } 
