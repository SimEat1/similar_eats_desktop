#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

// Entry point for a Windows desktop app.
int APIENTRY wWinMain(HINSTANCE instance,
                      HINSTANCE prev,
                      wchar_t* command_line,
                      int show_command) {
  // Attach console when present (e.g. "flutter run"), or create one if a debugger is attached.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // The "data" directory contains the Flutter assets and ICU data.
  flutter::DartProject project(L"data");

  FlutterWindow window(project);
  Win32Window::Point origin(0, 0);
  Win32Window::Size size(430, 900);
  // NOTE: Use Create(...) in current templates (not CreateAndShow).
 if (!window.Create(L"similar_eats_desktop", origin, size)) {
    ::CoUninitialize();
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  // Run the message loop.
  MSG msg;
  while (GetMessage(&msg, nullptr, 0, 0)) {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}


