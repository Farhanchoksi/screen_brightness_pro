#ifndef FLUTTER_PLUGIN_SCREEN_BRIGHTNESS_PRO_PLUGIN_H_
#define FLUTTER_PLUGIN_SCREEN_BRIGHTNESS_PRO_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _ScreenBrightnessProPlugin ScreenBrightnessProPlugin;
typedef struct {
  GObjectClass parent_class;
} ScreenBrightnessProPluginClass;

FLUTTER_PLUGIN_EXPORT GType screen_brightness_pro_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void screen_brightness_pro_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_SCREEN_BRIGHTNESS_PRO_PLUGIN_H_
