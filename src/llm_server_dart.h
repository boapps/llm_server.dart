#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

FFI_PLUGIN_EXPORT int start(int argc, char *argv[]);
FFI_PLUGIN_EXPORT int quit();
