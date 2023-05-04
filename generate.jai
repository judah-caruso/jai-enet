#run {
   set_build_options_dc(.{ do_output = false });

   opt  := get_build_options();
   args := opt.compile_time_command_line;

   debug := false;
   build := false;
   for args if it == {
      case "debug";    debug = it[0] != #char "!";
      case "make-lib"; build = it[0] != #char "!";
   }

   if build then do_build(debug);

   print("Generating bindings...\n");

   opts: Generate_Bindings_Options;
   array_add(*opts.system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);

   #if OS == .MACOS {
      array_add(*opts.system_include_paths, "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include");
      array_add(*opts.libpaths, "mac");
      array_add(*opts.libnames, "enet.dylib");
   }
   else #if OS == .WINDOWS {
      array_add(*opts.libpaths, "win");
      array_add(*opts.libnames, "enet.dll");
   }
   else #if OS == .LINUX {
      array_add(*opts.libpaths, "linux");
      array_add(*opts.libnames, "enet.so");
   }

   array_add(*opts.include_paths, "enet/include");
   array_add(*opts.source_files, "enet.h");

   if !generate_bindings(opts, "enet.jai") {
      compiler_set_workspace_status(.FAILED);
      return;
   }

   print("Done!\n");
}

do_build :: (debug: bool) {
   print("Building ENet...\n");

   buf: String_Builder;
   if debug then print_to_builder(*buf, "\n#define ENET_DEBUG\n");
   print_to_builder(*buf, C_FILE);

   str := builder_to_string(*buf);
   dyn := tprint("#define ENET_DLL\n%", str);

   write_entire_file("enet-static.c", str);
   defer file_delete("enet-static.c");

   write_entire_file("enet-dynamic.c", dyn);
   defer file_delete("enet-dynamic.c");

   #if OS == .WINDOWS {
      BASE :: "win";
   }
   else #if OS == .MACOS {
      BASE :: "mac";
   }
   else #if OS == .LINUX {
      BASE :: "linux";
   }

   make_directory_if_it_does_not_exist(BASE);

   name := tprint("%/enet", BASE);
   ok :=  build_cpp_dynamic_lib(name, "enet-dynamic.c", extra=.["-DENET_SHARED=1"], debug=debug);
   ok &&= build_cpp_static_lib(name, "enet-static.c",  extra=.["-DENET_STATIC=1"], debug=debug);

   if !ok {
      compiler_report("Unable to build ENet!");
      return;
   }

   print("Done!\n");
}

C_FILE :: #string END
#define ENET_IMPLEMENTATION
#include "enet/include/enet.h"
END;

#import "File";
#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Bindings_Generator";
