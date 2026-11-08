// nbfix.m - the two MTLHeap size queries NativeAdrenoMetal's device class never answers.
//
// SpringBoard dies with "-[NativeBridgeMetalDevice heapTextureSizeAndAlignWithDescriptor:]:
// unrecognized selector sent to instance" whenever a page opens (Safari, Settings > Wi-Fi
// after a re-entry).  The class is built at run time by objc_allocateClassPair() out of
// NBDDeviceMethods, and that list has newHeapWithDescriptor: but neither size query.
//
// Upstream implements both by asking the runtime; a descriptor the runtime refuses answers
// {0, 0}, "as Metal answers one it makes no texture of".  Here the answer is always {0, 0}:
// the caller then keeps the resource out of a heap and allocates it the ordinary way, which
// is the path this driver already serves.  No heap is ever created for it, so nothing else
// in the driver has to change.
//
// Loaded as a dependency of NativeAdrenoMetal.bundle, so it lands in every process that
// loads the driver (backboardd, SpringBoard, ...).  The class does not exist when this
// library initialises, hence the polling thread.

#include <objc/runtime.h>
#include <pthread.h>
#include <unistd.h>

typedef struct { unsigned long size; unsigned long align; } NBSizeAndAlign;

static NBSizeAndAlign nb_refuse_texture(id self, SEL cmd, id descriptor) {
    (void)self; (void)cmd; (void)descriptor;
    return (NBSizeAndAlign){0, 0};
}

static NBSizeAndAlign nb_refuse_buffer(id self, SEL cmd, unsigned long length, unsigned long options) {
    (void)self; (void)cmd; (void)length; (void)options;
    return (NBSizeAndAlign){0, 0};
}

static void *nb_install(void *unused) {
    (void)unused;
    for (int i = 0; i < 60000; i++) {          // ~60 s, then give up quietly
        Class cls = objc_lookUpClass("NativeBridgeMetalDevice");
        if (cls) {
            SEL texture = sel_registerName("heapTextureSizeAndAlignWithDescriptor:");
            SEL buffer  = sel_registerName("heapBufferSizeAndAlignWithLength:options:");
            if (!class_getInstanceMethod(cls, texture))
                class_addMethod(cls, texture, (IMP)nb_refuse_texture, "{NBSizeAndAlign=QQ}24@0:8@16");
            if (!class_getInstanceMethod(cls, buffer))
                class_addMethod(cls, buffer, (IMP)nb_refuse_buffer, "{NBSizeAndAlign=QQ}32@0:8Q16Q24");
            return NULL;
        }
        usleep(1000);
    }
    return NULL;
}

__attribute__((constructor)) static void nb_start(void) {
    pthread_t thread;
    if (pthread_create(&thread, NULL, nb_install, NULL) == 0)
        pthread_detach(thread);
}
