#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include <hx/CFFI.h>
#include <FirebaseAppInterface.h>

extern "C" {

    void firebase_main () {
	    val_int(0); // Fix Neko init
    }
    DEFINE_ENTRY_POINT (firebase_main);

    extern "C" int firebase_register_prims () {
        extension_ios_firebase::init();
        return 0; 
    }
    
    AutoGCRoot* onRCSuccessHandler = NULL;
    void getRemoteConfig(value onSuccess)
    {
        if (onRCSuccessHandler == NULL)
        {
            onRCSuccessHandler = new AutoGCRoot(onSuccess);
        }
        //std::cout << "getRemoteConfig ok!\n";
        extension_ios_firebase::requestRemoteConfig();
    }
    DEFINE_PRIM(getRemoteConfig, 1);
    
    extern "C" void responseRemoteConfig(const char* config)
    {
        //std::cout << config;
        if (onRCSuccessHandler == NULL)
        {
            return;
        }
        val_call1(onRCSuccessHandler->get(), alloc_string(config));
    }
}
