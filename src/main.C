#include "AppFactory.h"
#include "Moose.h"
#include "MooseApp.h"
#include "MooseInit.h"
#include "RedbackApp.h"

// Create a performance log
PerfLog Moose::perf_log("Redback");

// Begin the main program.
int
main(int argc, char * argv[])
{
  // Initialize MPI, solvers and MOOSE
  MooseInit init(argc, argv);

  // Register this application's MooseApp and any it depends on
  RedbackApp::registerApps();

  // Create an instance of the application and store it in a smart pointer for easy cleanup
  std::shared_ptr<MooseApp> app = AppFactory::createAppShared("RedbackApp", argc, argv);

  // Execute the application
  app->run();

  return 0;
}
